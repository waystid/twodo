import Foundation
import SwiftUI
import UserNotifications

@MainActor
class NotificationViewModel: ObservableObject {
    @Published var notifications: [Notification] = []
    @Published var unreadCount: Int = 0
    @Published var preferences: NotificationPreferences?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Fetch Notifications
    func fetchNotifications(unreadOnly: Bool = false) async {
        isLoading = true
        errorMessage = nil

        var queryItems: [URLQueryItem] = []
        if unreadOnly {
            queryItems.append(URLQueryItem(name: "unread", value: "true"))
        }

        do {
            let response: GetNotificationsResponse = try await apiClient.request(
                .getNotifications,
                queryItems: queryItems.isEmpty ? nil : queryItems
            )
            notifications = response.notifications
            unreadCount = response.unreadCount
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Mark as Read
    func markAsRead(notificationIds: [String]) async {
        // Optimistic update
        let originalNotifications = notifications
        let originalUnreadCount = unreadCount

        for id in notificationIds {
            if let index = notifications.firstIndex(where: { $0.id == id }) {
                var notification = notifications[index]
                if !notification.isRead {
                    notification.isRead = true
                    notifications[index] = notification
                    unreadCount = max(0, unreadCount - 1)
                }
            }
        }

        do {
            let request = MarkNotificationReadRequest(notificationIds: notificationIds)
            let _: EmptyResponse = try await apiClient.request(.markNotificationsRead, body: request)
        } catch {
            // Revert on error
            notifications = originalNotifications
            unreadCount = originalUnreadCount
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Mark All as Read
    func markAllAsRead() async {
        let unreadIds = notifications.filter { !$0.isRead }.map { $0.id }
        if !unreadIds.isEmpty {
            await markAsRead(notificationIds: unreadIds)
        }
    }

    // MARK: - Delete Notification
    func deleteNotification(notificationId: String) async -> Bool {
        // Optimistic update
        let originalNotifications = notifications
        let originalUnreadCount = unreadCount

        if let index = notifications.firstIndex(where: { $0.id == notificationId }) {
            let notification = notifications[index]
            notifications.remove(at: index)
            if !notification.isRead {
                unreadCount = max(0, unreadCount - 1)
            }
        }

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteNotification(notificationId))
            return true
        } catch {
            // Revert on error
            notifications = originalNotifications
            unreadCount = originalUnreadCount
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Fetch Preferences
    func fetchPreferences() async {
        do {
            let response: GetNotificationPreferencesResponse = try await apiClient.request(.getNotificationPreferences)
            preferences = response.preferences
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update Preferences
    func updatePreferences(
        emailNotifications: Bool? = nil,
        pushNotifications: Bool? = nil,
        taskReminders: Bool? = nil,
        routineReminders: Bool? = nil,
        eventReminders: Bool? = nil,
        partnerActivity: Bool? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateNotificationPreferencesRequest(
                emailNotifications: emailNotifications,
                pushNotifications: pushNotifications,
                taskReminders: taskReminders,
                routineReminders: routineReminders,
                eventReminders: eventReminders,
                partnerActivity: partnerActivity
            )
            let response: GetNotificationPreferencesResponse = try await apiClient.request(
                .updateNotificationPreferences,
                body: request
            )
            preferences = response.preferences
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Push Notification Permissions
    func requestPushNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            if granted {
                await MainActor.run {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            return granted
        } catch {
            errorMessage = "Failed to request notification permission: \(error.localizedDescription)"
            return false
        }
    }

    func checkPushNotificationPermission() async -> UNAuthorizationStatus {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        return settings.authorizationStatus
    }

    // MARK: - Register Push Token
    func registerPushToken(_ token: Data) async {
        let tokenString = token.map { String(format: "%02.2hhx", $0) }.joined()

        do {
            let request = RegisterPushTokenRequest(token: tokenString, platform: "ios")
            let _: EmptyResponse = try await apiClient.request(.registerPushToken, body: request)
        } catch {
            errorMessage = "Failed to register push token: \(error.localizedDescription)"
        }
    }

    // MARK: - Helper: Get Unread Notifications
    var unreadNotifications: [Notification] {
        notifications.filter { !$0.isRead }
    }

    // MARK: - Helper: Group Notifications by Date
    func groupedNotifications() -> [(String, [Notification])] {
        let calendar = Calendar.current
        let now = Date()

        var groups: [String: [Notification]] = [
            "Today": [],
            "Yesterday": [],
            "This Week": [],
            "Earlier": []
        ]

        for notification in notifications {
            if calendar.isDateInToday(notification.createdAt) {
                groups["Today"]?.append(notification)
            } else if calendar.isDateInYesterday(notification.createdAt) {
                groups["Yesterday"]?.append(notification)
            } else if calendar.isDate(notification.createdAt, equalTo: now, toGranularity: .weekOfYear) {
                groups["This Week"]?.append(notification)
            } else {
                groups["Earlier"]?.append(notification)
            }
        }

        // Return only non-empty groups in order
        return [
            ("Today", groups["Today"] ?? []),
            ("Yesterday", groups["Yesterday"] ?? []),
            ("This Week", groups["This Week"] ?? []),
            ("Earlier", groups["Earlier"] ?? [])
        ].filter { !$0.1.isEmpty }
    }

    // MARK: - Helper: Handle Notification Tap
    func handleNotificationTap(_ notification: Notification) -> NotificationAction? {
        // Mark as read when tapped
        Task {
            await markAsRead(notificationIds: [notification.id])
        }

        // Determine navigation action based on type and data
        guard let data = notification.data else { return nil }

        switch notification.type {
        case .taskAssigned, .taskCompleted, .taskDueSoon, .taskOverdue:
            if let taskId = data.taskId {
                return .navigateToTask(taskId)
            }
        case .routineReminder, .routineMissed:
            if let routineId = data.routineId {
                return .navigateToRoutine(routineId)
            }
        case .eventReminder, .eventStarting:
            if let eventId = data.eventId {
                return .navigateToEvent(eventId)
            }
        case .noteShared:
            if let noteId = data.noteId {
                return .navigateToNote(noteId)
            }
        case .coupleInvite:
            return .navigateToCoupleSetup
        case .partnerActivity, .general:
            break
        }

        return nil
    }
}

// MARK: - Notification Action
enum NotificationAction {
    case navigateToTask(String)
    case navigateToRoutine(String)
    case navigateToEvent(String)
    case navigateToNote(String)
    case navigateToCoupleSetup
}
