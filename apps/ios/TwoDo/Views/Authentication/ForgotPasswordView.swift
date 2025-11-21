import SwiftUI

struct ForgotPasswordView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    @State private var email = ""
    @State private var showingSuccessAlert = false

    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue.gradient)

                Text("Reset Password")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Enter your email address and we'll send you a link to reset your password")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)

            // Form
            VStack(spacing: 16) {
                CustomTextField(
                    placeholder: "Email",
                    text: $email,
                    icon: "envelope"
                )
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

                // Error message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                CustomButton(title: "Send Reset Link", isLoading: authViewModel.isLoading) {
                    Task {
                        await authViewModel.forgotPassword(email: email)
                        showingSuccessAlert = true
                    }
                }
                .disabled(email.isEmpty)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Email Sent", isPresented: $showingSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("If an account exists with that email, we've sent you a password reset link. Please check your inbox.")
        }
    }
}

#Preview {
    NavigationStack {
        ForgotPasswordView()
            .environmentObject(AuthViewModel())
    }
}
