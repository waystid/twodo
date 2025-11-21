import Foundation
import Security

actor KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.twodo.app"
    private let accessTokenKey = "accessToken"
    private let refreshTokenKey = "refreshToken"

    private init() {}

    // MARK: - Access Token
    func saveAccessToken(_ token: String) async {
        await save(token, for: accessTokenKey)
    }

    func getAccessToken() async -> String? {
        return await get(for: accessTokenKey)
    }

    func deleteAccessToken() async {
        await delete(for: accessTokenKey)
    }

    // MARK: - Refresh Token
    func saveRefreshToken(_ token: String) async {
        await save(token, for: refreshTokenKey)
    }

    func getRefreshToken() async -> String? {
        return await get(for: refreshTokenKey)
    }

    func deleteRefreshToken() async {
        await delete(for: refreshTokenKey)
    }

    // MARK: - Delete All
    func deleteTokens() async {
        await deleteAccessToken()
        await deleteRefreshToken()
    }

    // MARK: - Private Helpers
    private func save(_ value: String, for key: String) async {
        guard let data = value.data(using: .utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]

        // Delete any existing item
        SecItemDelete(query as CFDictionary)

        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)

        if status != errSecSuccess {
            print("Keychain save error: \(status)")
        }
    }

    private func get(for key: String) async -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }

        return value
    }

    private func delete(for key: String) async {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        if status != errSecSuccess && status != errSecItemNotFound {
            print("Keychain delete error: \(status)")
        }
    }
}
