import Foundation

struct Couple: Codable, Identifiable {
    let id: String
    var name: String
    var inviteCode: String?
    var inviteCodeExpiresAt: Date?
    let createdAt: Date
    let updatedAt: Date
}

struct CoupleWithMembers: Codable {
    let couple: Couple
    let members: [User]
}

// MARK: - Couple Request/Response Models

struct CreateCoupleRequest: Codable {
    let name: String
}

struct CreateCoupleResponse: Codable {
    let couple: Couple
}

struct JoinCoupleRequest: Codable {
    let inviteCode: String
}

struct JoinCoupleResponse: Codable {
    let couple: Couple
}

struct GenerateInviteResponse: Codable {
    let inviteCode: String
    let expiresAt: Date
}

struct GetCoupleResponse: Codable {
    let couple: Couple
    let members: [User]
}

struct UpdateCoupleRequest: Codable {
    let name: String
}

struct UpdateCoupleResponse: Codable {
    let couple: Couple
}
