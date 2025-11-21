import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Welcome, \(authViewModel.currentUser?.displayName ?? "User")!")
                    .font(.title2)
                    .padding()

                Text("This is where your tasks, routines, and events will appear.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                Button("Logout") {
                    authViewModel.logout()
                }
                .foregroundStyle(.red)
                .padding()
            }
            .navigationTitle("TwoDo")
        }
    }
}

#Preview {
    DashboardView()
        .environmentObject(AuthViewModel())
}
