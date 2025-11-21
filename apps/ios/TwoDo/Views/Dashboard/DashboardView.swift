import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0
    @StateObject private var notificationViewModel = NotificationViewModel()

    var body: some View {
        TabView(selection: $selectedTab) {
            TaskListView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(0)

            RoutinesView()
                .tabItem {
                    Label("Routines", systemImage: "repeat.circle")
                }
                .tag(1)

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(2)

            NotificationsView()
                .tabItem {
                    Label("Notifications", systemImage: "bell")
                }
                .badge(notificationViewModel.unreadCount)
                .tag(3)
        }
        .task {
            // Fetch notification count on app launch
            await notificationViewModel.fetchNotifications()
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
