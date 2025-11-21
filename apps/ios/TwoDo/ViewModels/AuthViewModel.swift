import Foundation
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Check Auth Status
    func checkAuthStatus() {
        Task {
            guard await KeychainManager.shared.getAccessToken() != nil else {
                isAuthenticated = false
                return
            }

            do {
                let response: MeResponse = try await apiClient.request(.me)
                currentUser = response.user
                isAuthenticated = true
            } catch {
                // Token invalid, clear and logout
                await KeychainManager.shared.deleteTokens()
                isAuthenticated = false
            }
        }
    }

    // MARK: - Login
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = LoginRequest(email: email, password: password)
            let response: LoginResponse = try await apiClient.request(.login, body: request)

            // Save tokens
            await KeychainManager.shared.saveAccessToken(response.accessToken)
            await KeychainManager.shared.saveRefreshToken(response.refreshToken)

            // Update state
            currentUser = response.user
            isAuthenticated = true
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Register
    func register(email: String, password: String, displayName: String, timezone: String = "UTC") async {
        isLoading = true
        errorMessage = nil

        do {
            let request = RegisterRequest(
                email: email,
                password: password,
                displayName: displayName,
                timezone: timezone
            )
            let _: RegisterResponse = try await apiClient.request(.register, body: request)

            isLoading = false
            // Success message - user needs to verify email
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Verify Email
    func verifyEmail(token: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = VerifyEmailRequest(token: token)
            let _: VerifyEmailResponse = try await apiClient.request(.verifyEmail, body: request)

            isLoading = false
            // Email verified, user can now login
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Forgot Password
    func forgotPassword(email: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = ForgotPasswordRequest(email: email)
            let _: ForgotPasswordResponse = try await apiClient.request(.forgotPassword, body: request)

            isLoading = false
            // Password reset email sent
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Reset Password
    func resetPassword(token: String, newPassword: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = ResetPasswordRequest(token: token, newPassword: newPassword)
            let _: ResetPasswordResponse = try await apiClient.request(.resetPassword, body: request)

            isLoading = false
            // Password reset successful
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Logout
    func logout() {
        Task {
            do {
                let _: EmptyResponse = try await apiClient.request(.logout)
            } catch {
                // Ignore logout errors
            }

            // Clear tokens and state
            await KeychainManager.shared.deleteTokens()
            isAuthenticated = false
            currentUser = nil
        }
    }
}
