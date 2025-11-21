import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum APIEndpoint {
    // MARK: - Authentication
    case register
    case login
    case logout
    case refreshToken
    case me
    case verifyEmail
    case forgotPassword
    case resetPassword

    // MARK: - Couples
    case createCouple
    case getCouple
    case generateInvite
    case joinCouple
    case updateCouple(String)
    case leaveCouple(String)

    // MARK: - Tasks
    case getTaskLists
    case createTaskList
    case getTasks(String)
    case createTask
    case updateTask(String)
    case completeTask(String)
    case assignTask(String)
    case deleteTask(String)

    // MARK: - Routines
    case getRoutines
    case createRoutine
    case getRoutine(String)
    case updateRoutine(String)
    case deleteRoutine(String)
    case completeOccurrence(String, String)
    case skipOccurrence(String, String)
    case getRoutineStats(String)

    // MARK: - Events
    case getEvents
    case getUpcomingEvents
    case createEvent
    case getEvent(String)
    case updateEvent(String)
    case deleteEvent(String)

    // MARK: - Notifications
    case getNotifications
    case getUnreadCount
    case markAsRead(String)
    case markNotificationsRead
    case markAllAsRead
    case deleteNotification(String)
    case getNotificationPreferences
    case updateNotificationPreferences
    case registerPushToken

    // MARK: - Notes
    case getNotes(String, String) // type, entityId
    case createNote
    case updateNote(String)
    case deleteNote(String)

    // MARK: - Settings
    case getSettings
    case updateProfile
    case updatePassword
    case updateCoupleSettings

    var path: String {
        switch self {
        // Authentication
        case .register: return "/auth/register"
        case .login: return "/auth/login"
        case .logout: return "/auth/logout"
        case .refreshToken: return "/auth/refresh"
        case .me: return "/auth/me"
        case .verifyEmail: return "/auth/verify-email"
        case .forgotPassword: return "/auth/forgot-password"
        case .resetPassword: return "/auth/reset-password"

        // Couples
        case .createCouple: return "/couples"
        case .getCouple: return "/couples/me"
        case .generateInvite: return "/couples/generate-invite"
        case .joinCouple: return "/couples/join"
        case .updateCouple(let id): return "/couples/\(id)"
        case .leaveCouple(let id): return "/couples/\(id)/leave"

        // Tasks
        case .getTaskLists: return "/lists"
        case .createTaskList: return "/lists"
        case .getTasks(let listId): return "/lists/\(listId)/tasks"
        case .createTask: return "/tasks"
        case .updateTask(let id): return "/tasks/\(id)"
        case .completeTask(let id): return "/tasks/\(id)/complete"
        case .assignTask(let id): return "/tasks/\(id)/assign"
        case .deleteTask(let id): return "/tasks/\(id)"

        // Routines
        case .getRoutines: return "/routines"
        case .createRoutine: return "/routines"
        case .getRoutine(let id): return "/routines/\(id)"
        case .updateRoutine(let id): return "/routines/\(id)"
        case .deleteRoutine(let id): return "/routines/\(id)"
        case .completeOccurrence(let routineId, let occurrenceId):
            return "/routines/\(routineId)/occurrences/\(occurrenceId)/complete"
        case .skipOccurrence(let routineId, let occurrenceId):
            return "/routines/\(routineId)/occurrences/\(occurrenceId)/skip"
        case .getRoutineStats(let id): return "/routines/\(id)/stats"

        // Events
        case .getEvents: return "/events"
        case .getUpcomingEvents: return "/events/upcoming"
        case .createEvent: return "/events"
        case .getEvent(let id): return "/events/\(id)"
        case .updateEvent(let id): return "/events/\(id)"
        case .deleteEvent(let id): return "/events/\(id)"

        // Notifications
        case .getNotifications: return "/notifications"
        case .getUnreadCount: return "/notifications/unread-count"
        case .markAsRead(let id): return "/notifications/\(id)/read"
        case .markNotificationsRead: return "/notifications/read"
        case .markAllAsRead: return "/notifications/read-all"
        case .deleteNotification(let id): return "/notifications/\(id)"
        case .getNotificationPreferences: return "/notifications/preferences"
        case .updateNotificationPreferences: return "/notifications/preferences"
        case .registerPushToken: return "/notifications/push-token"

        // Notes
        case .getNotes(let type, let entityId): return "/notes/\(type)/\(entityId)"
        case .createNote: return "/notes"
        case .updateNote(let id): return "/notes/\(id)"
        case .deleteNote(let id): return "/notes/\(id)"

        // Settings
        case .getSettings: return "/settings"
        case .updateProfile: return "/settings/profile"
        case .updatePassword: return "/settings/password"
        case .updateCoupleSettings: return "/settings/couple"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .register, .login, .verifyEmail, .forgotPassword, .resetPassword,
             .createCouple, .generateInvite, .joinCouple,
             .createTaskList, .createTask, .completeTask, .assignTask,
             .createRoutine, .completeOccurrence, .skipOccurrence,
             .createEvent, .createNote,
             .markNotificationsRead, .registerPushToken:
            return .post

        case .updateCouple, .updateTask, .updateRoutine, .updateEvent,
             .markAsRead, .markAllAsRead, .updateNote,
             .updateProfile, .updatePassword, .updateCoupleSettings,
             .updateNotificationPreferences:
            return .put

        case .deleteTask, .deleteRoutine, .deleteEvent, .deleteNotification,
             .deleteNote, .leaveCouple, .logout:
            return .delete

        default:
            return .get
        }
    }

    var requiresAuth: Bool {
        switch self {
        case .register, .login, .verifyEmail, .forgotPassword, .resetPassword:
            return false
        default:
            return true
        }
    }
}
