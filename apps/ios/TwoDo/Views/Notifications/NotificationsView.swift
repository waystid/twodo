import SwiftUI

struct NotificationsView: View {
    @StateObject private var viewModel = NotificationViewModel()
    @State private var showSettings = false
    @State private var selectedNotification: Notification?
    @State private var notificationAction: NotificationAction?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.notifications.isEmpty {
                    ProgressView()
                } else if viewModel.notifications.isEmpty {
                    EmptyNotificationsView()
                } else {
                    NotificationsList(
                        viewModel: viewModel,
                        onNotificationTap: { notification in
                            if let action = viewModel.handleNotificationTap(notification) {
                                notificationAction = action
                            }
                        }
                    )
                }
            }
            .navigationTitle("Notifications")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if !viewModel.notifications.isEmpty && viewModel.unreadCount > 0 {
                        Button {
                            Task {
                                await viewModel.markAllAsRead()
                            }
                        } label: {
                            Text("Mark All Read")
                                .font(.subheadline)
                        }
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                NotificationSettingsView(viewModel: viewModel)
            }
            .refreshable {
                await viewModel.fetchNotifications()
            }
            .task {
                await viewModel.fetchNotifications()
            }
        }
    }
}

// MARK: - Notifications List
struct NotificationsList: View {
    @ObservedObject var viewModel: NotificationViewModel
    let onNotificationTap: (Notification) -> Void

    var body: some View {
        List {
            ForEach(viewModel.groupedNotifications(), id: \.0) { section, notifications in
                Section(section) {
                    ForEach(notifications) { notification in
                        NotificationRowView(
                            notification: notification,
                            onTap: {
                                onNotificationTap(notification)
                            }
                        )
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            if !notification.isRead {
                                Button {
                                    Task {
                                        await viewModel.markAsRead(notificationIds: [notification.id])
                                    }
                                } label: {
                                    Label("Read", systemImage: "checkmark")
                                }
                                .tint(.blue)
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                Task {
                                    await viewModel.deleteNotification(notificationId: notification.id)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Notification Row
struct NotificationRowView: View {
    let notification: Notification
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: notification.type.icon)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                    .frame(width: 32, height: 32)
                    .background(iconColor.opacity(0.1))
                    .clipShape(Circle())

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .fontWeight(notification.isRead ? .regular : .semibold)

                    Text(notification.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)

                    Text(notification.createdAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                // Unread indicator
                if !notification.isRead {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch notification.type.color {
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "blue": return .blue
        case "purple": return .purple
        case "pink": return .pink
        case "teal": return .teal
        default: return .gray
        }
    }
}

// MARK: - Empty State
struct EmptyNotificationsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No notifications")
                .font(.title3)
                .fontWeight(.semibold)

            Text("You're all caught up!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Badge View (for tab bar)
struct NotificationBadgeView: View {
    let count: Int

    var body: some View {
        if count > 0 {
            Text("\(min(count, 99))\(count > 99 ? "+" : "")")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.red)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    NotificationsView()
}
