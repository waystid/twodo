import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignup = false
    @State private var showForgotPassword = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.pink.gradient)

                    Text("TwoDo")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Life together, organized")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)

                // Form
                VStack(spacing: 16) {
                    // Email
                    CustomTextField(
                        placeholder: "Email",
                        text: $email,
                        icon: "envelope"
                    )
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                    // Password
                    CustomTextField(
                        placeholder: "Password",
                        text: $password,
                        icon: "lock",
                        isSecure: true
                    )

                    // Error message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Login button
                    CustomButton(title: "Login", isLoading: authViewModel.isLoading) {
                        Task {
                            await authViewModel.login(email: email, password: password)
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty)

                    // Forgot password
                    Button("Forgot Password?") {
                        showForgotPassword = true
                    }
                    .font(.subheadline)
                    .foregroundStyle(.blue)
                }
                .padding(.horizontal)

                Spacer()

                // Sign up link
                Button {
                    showSignup = true
                } label: {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundStyle(.secondary)
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .padding(.bottom, 40)
            }
            .navigationDestination(isPresented: $showSignup) {
                SignupView()
            }
            .navigationDestination(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
