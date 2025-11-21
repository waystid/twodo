import SwiftUI

struct SignupView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showingSuccessAlert = false
    @State private var passwordsMatch = true

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Join TwoDo and organize life with your partner")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Form
                VStack(spacing: 16) {
                    // Display Name
                    CustomTextField(
                        placeholder: "Display Name",
                        text: $displayName,
                        icon: "person"
                    )

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

                    // Confirm Password
                    CustomTextField(
                        placeholder: "Confirm Password",
                        text: $confirmPassword,
                        icon: "lock",
                        isSecure: true
                    )
                    .onChange(of: confirmPassword) { _, newValue in
                        passwordsMatch = password == newValue
                    }

                    if !passwordsMatch && !confirmPassword.isEmpty {
                        Text("Passwords do not match")
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Error message
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Sign up button
                    CustomButton(title: "Sign Up", isLoading: authViewModel.isLoading) {
                        Task {
                            await authViewModel.register(
                                email: email,
                                password: password,
                                displayName: displayName
                            )
                            showingSuccessAlert = true
                        }
                    }
                    .disabled(!isFormValid)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 40)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Check Your Email", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("We've sent you a verification email. Please check your inbox and verify your email address before logging in.")
        }
    }

    var isFormValid: Bool {
        !displayName.isEmpty &&
        !email.isEmpty &&
        !password.isEmpty &&
        password.count >= 8 &&
        passwordsMatch
    }
}

#Preview {
    NavigationStack {
        SignupView()
            .environmentObject(AuthViewModel())
    }
}
