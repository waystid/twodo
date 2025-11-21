import Foundation

enum RoutineFrequency: String, Codable {
    case daily
    case weekly
    case monthly
}

struct RoutineSchedule: Codable {
    var frequency: RoutineFrequency
    var daysOfWeek: [Int]? // 0 = Sunday, 6 = Saturday
    var dayOfMonth: Int? // 1-31

    // Helper to check if routine is due on a given date
    func isDueOn(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date) - 1 // Convert to 0-6
        let day = calendar.component(.day, from: date)

        switch frequency {
        case .daily:
            return true
        case .weekly:
            return daysOfWeek?.contains(weekday) ?? false
        case .monthly:
            return dayOfMonth == day
        }
    }
}

struct Routine: Codable, Identifiable {
    let id: String
    let coupleId: String
    var name: String
    var description: String?
    var schedule: RoutineSchedule
    var assignedToUserId: String?
    let createdById: String
    let createdAt: Date
    let updatedAt: Date
}

struct RoutineOccurrence: Codable, Identifiable {
    let id: String
    let routineId: String
    let scheduledDate: Date
    var completedAt: Date?
    var completedById: String?
    var skipped: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct RoutineWithOccurrences: Codable {
    let routine: Routine
    let occurrences: [RoutineOccurrence]
}

struct RoutineStats: Codable {
    var currentStreak: Int
    var longestStreak: Int
    var totalCompleted: Int
    var completionRate: Double
}

// MARK: - Routine Request/Response Models

struct GetRoutinesResponse: Codable {
    let routines: [Routine]
}

struct CreateRoutineRequest: Codable {
    let name: String
    let description: String?
    let schedule: RoutineSchedule
    let assignedToUserId: String?
}

struct CreateRoutineResponse: Codable {
    let routine: Routine
}

struct GetRoutineResponse: Codable {
    let routine: Routine
    let occurrences: [RoutineOccurrence]
}

struct UpdateRoutineRequest: Codable {
    let name: String?
    let description: String?
    let schedule: RoutineSchedule?
    let assignedToUserId: String?
}

struct UpdateRoutineResponse: Codable {
    let routine: Routine
}

struct CompleteOccurrenceResponse: Codable {
    let occurrence: RoutineOccurrence
}

struct SkipOccurrenceResponse: Codable {
    let occurrence: RoutineOccurrence
}

struct GetRoutineStatsResponse: Codable {
    let stats: RoutineStats
}
