import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.currentUser?.coupleId != nil {
                    DashboardView()
                } else {
                    CoupleSetupView()
                }
            } else {
                LoginView()
            }
        }
        .onAppear {
            authViewModel.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}
