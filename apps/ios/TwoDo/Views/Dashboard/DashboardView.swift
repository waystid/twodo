import SwiftUI

struct DashboardView: View {
    @State private var selectedTab = 0

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
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
