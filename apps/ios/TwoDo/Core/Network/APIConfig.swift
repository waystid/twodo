import Foundation

struct APIConfig {
    // MARK: - Base Configuration
    static let baseURL = "http://localhost:3000" // Change to production URL for release
    static let apiVersion = "/api"
    static let timeout: TimeInterval = 30

    // MARK: - Environment
    enum Environment {
        case development
        case staging
        case production

        var baseURL: String {
            switch self {
            case .development:
                return "http://localhost:3000"
            case .staging:
                return "https://staging-api.twodo.app"
            case .production:
                return "https://api.twodo.app"
            }
        }
    }

    static var currentEnvironment: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }

    static var fullBaseURL: String {
        return currentEnvironment.baseURL + apiVersion
    }
}
