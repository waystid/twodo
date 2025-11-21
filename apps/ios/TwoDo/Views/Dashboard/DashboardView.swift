import SwiftUI

struct DashboardView: View {
    var body: some View {
        TaskListView()
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
