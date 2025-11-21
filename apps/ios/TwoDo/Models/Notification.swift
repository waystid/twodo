import Foundation

// MARK: - Notification
struct Notification: Codable, Identifiable {
    let id: String
    let coupleId: String
    let userId: String
    var type: NotificationType
    var title: String
    var message: String
    var isRead: Bool
    var data: NotificationData?
    let createdAt: Date
}

// MARK: - Notification Type
enum NotificationType: String, Codable, CaseIterable {
    case taskAssigned = "task_assigned"
    case taskCompleted = "task_completed"
    case taskDueSoon = "task_due_soon"
    case taskOverdue = "task_overdue"
    case routineReminder = "routine_reminder"
    case routineMissed = "routine_missed"
    case eventReminder = "event_reminder"
    case eventStarting = "event_starting"
    case partnerActivity = "partner_activity"
    case coupleInvite = "couple_invite"
    case noteShared = "note_shared"
    case general = "general"

    var displayName: String {
        switch self {
        case .taskAssigned: return "Task Assigned"
        case .taskCompleted: return "Task Completed"
        case .taskDueSoon: return "Task Due Soon"
        case .taskOverdue: return "Task Overdue"
        case .routineReminder: return "Routine Reminder"
        case .routineMissed: return "Routine Missed"
        case .eventReminder: return "Event Reminder"
        case .eventStarting: return "Event Starting"
        case .partnerActivity: return "Partner Activity"
        case .coupleInvite: return "Couple Invite"
        case .noteShared: return "Note Shared"
        case .general: return "General"
        }
    }

    var icon: String {
        switch self {
        case .taskAssigned, .taskCompleted: return "checkmark.circle.fill"
        case .taskDueSoon, .taskOverdue: return "clock.fill"
        case .routineReminder, .routineMissed: return "repeat.circle.fill"
        case .eventReminder, .eventStarting: return "calendar.circle.fill"
        case .partnerActivity: return "person.circle.fill"
        case .coupleInvite: return "heart.circle.fill"
        case .noteShared: return "note.text"
        case .general: return "bell.fill"
        }
    }

    var color: String {
        switch self {
        case .taskAssigned, .taskCompleted: return "green"
        case .taskDueSoon: return "orange"
        case .taskOverdue: return "red"
        case .routineReminder, .routineMissed: return "blue"
        case .eventReminder, .eventStarting: return "purple"
        case .partnerActivity: return "pink"
        case .coupleInvite: return "red"
        case .noteShared: return "teal"
        case .general: return "gray"
        }
    }
}

// MARK: - Notification Data
struct NotificationData: Codable {
    var taskId: String?
    var routineId: String?
    var eventId: String?
    var noteId: String?
    var actionUrl: String?
}

// MARK: - API Request/Response Models

struct GetNotificationsResponse: Codable {
    let notifications: [Notification]
    let unreadCount: Int
}

struct MarkNotificationReadRequest: Codable {
    let notificationIds: [String]
}

struct UpdateNotificationPreferencesRequest: Codable {
    var emailNotifications: Bool?
    var pushNotifications: Bool?
    var taskReminders: Bool?
    var routineReminders: Bool?
    var eventReminders: Bool?
    var partnerActivity: Bool?
}

struct GetNotificationPreferencesResponse: Codable {
    let preferences: NotificationPreferences
}

struct NotificationPreferences: Codable {
    var emailNotifications: Bool
    var pushNotifications: Bool
    var taskReminders: Bool
    var routineReminders: Bool
    var eventReminders: Bool
    var partnerActivity: Bool
}

// MARK: - Push Notification Registration

struct RegisterPushTokenRequest: Codable {
    let token: String
    let platform: String // "ios"
}

struct EmptyResponse: Codable {}
