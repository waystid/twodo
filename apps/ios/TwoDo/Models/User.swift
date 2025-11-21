import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    var displayName: String
    var avatarUrl: String?
    var timezone: String
    let emailVerified: Bool
    let coupleId: String?
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Authentication Request/Response Models

struct RegisterRequest: Codable {
    let email: String
    let password: String
    let displayName: String
    let timezone: String?
}

struct RegisterResponse: Codable {
    let user: User
    let message: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let user: User
}

struct VerifyEmailRequest: Codable {
    let token: String
}

struct VerifyEmailResponse: Codable {
    let message: String
}

struct ForgotPasswordRequest: Codable {
    let email: String
}

struct ForgotPasswordResponse: Codable {
    let message: String
}

struct ResetPasswordRequest: Codable {
    let token: String
    let newPassword: String
}

struct ResetPasswordResponse: Codable {
    let message: String
}

struct MeResponse: Codable {
    let user: User
}
