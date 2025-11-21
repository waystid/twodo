import Foundation

actor APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = APIConfig.timeout
        configuration.timeoutIntervalForResource = APIConfig.timeout
        self.session = URLSession(configuration: configuration)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Main Request Method
    func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        body: Encodable? = nil,
        queryItems: [URLQueryItem]? = nil
    ) async throws -> T {
        let request = try await buildRequest(endpoint, body: body, queryItems: queryItems)

        do {
            let (data, response) = try await session.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            try await handleHTTPResponse(httpResponse, data: data)

            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }

            do {
                let decoded = try decoder.decode(T.self, from: data)
                return decoded
            } catch {
                print("Decoding error: \(error)")
                print("Response data: \(String(data: data, encoding: .utf8) ?? "nil")")
                throw APIError.decodingError(error)
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }

    // MARK: - Request Building
    private func buildRequest(
        _ endpoint: APIEndpoint,
        body: Encodable?,
        queryItems: [URLQueryItem]?
    ) async throws -> URLRequest {
        var urlComponents = URLComponents(string: APIConfig.fullBaseURL + endpoint.path)

        if let queryItems = queryItems {
            urlComponents?.queryItems = queryItems
        }

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add authorization header if needed
        if endpoint.requiresAuth {
            if let token = await KeychainManager.shared.getAccessToken() {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }

        // Add body if present
        if let body = body {
            do {
                request.httpBody = try encoder.encode(body)
            } catch {
                throw APIError.encodingError(error)
            }
        }

        return request
    }

    // MARK: - Response Handling
    private func handleHTTPResponse(_ response: HTTPURLResponse, data: Data) async throws {
        switch response.statusCode {
        case 200...299:
            return

        case 401:
            // Try to refresh token
            if await tryRefreshToken() {
                return // Will retry the original request
            }
            throw APIError.unauthorized

        case 403:
            throw APIError.forbidden

        case 404:
            throw APIError.notFound

        case 500...599:
            throw APIError.serverError(response.statusCode)

        default:
            // Try to decode error message
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                throw APIError.networkError(NSError(
                    domain: "TwoDoAPI",
                    code: response.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: errorResponse.error]
                ))
            }
            throw APIError.invalidResponse
        }
    }

    // MARK: - Token Refresh
    private func tryRefreshToken() async -> Bool {
        guard let refreshToken = await KeychainManager.shared.getRefreshToken() else {
            return false
        }

        do {
            let response: TokenResponse = try await request(
                .refreshToken,
                body: RefreshTokenRequest(refreshToken: refreshToken)
            )

            await KeychainManager.shared.saveAccessToken(response.accessToken)
            if let newRefreshToken = response.refreshToken {
                await KeychainManager.shared.saveRefreshToken(newRefreshToken)
            }

            return true
        } catch {
            // Refresh failed, clear tokens
            await KeychainManager.shared.deleteTokens()
            return false
        }
    }
}

// MARK: - Helper Types
struct EmptyResponse: Codable {}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct TokenResponse: Codable {
    let accessToken: String
    let refreshToken: String?
}
