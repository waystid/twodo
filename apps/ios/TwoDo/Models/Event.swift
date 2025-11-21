import Foundation

enum RecurrenceFrequency: String, Codable {
    case daily
    case weekly
    case monthly
    case yearly
}

struct EventRecurrence: Codable {
    var frequency: RecurrenceFrequency
    var interval: Int // e.g., every 2 weeks
    var until: Date?
}

struct Event: Codable, Identifiable {
    let id: String
    let coupleId: String
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date?
    var isAllDay: Bool
    var location: String?
    var reminderMinutes: Int?
    var recurrence: EventRecurrence?
    var assignedToUserId: String?
    let createdById: String
    let createdAt: Date
    let updatedAt: Date
}

struct EventWithDetails: Codable, Identifiable {
    let id: String
    let coupleId: String
    var title: String
    var description: String?
    var startDate: Date
    var endDate: Date?
    var isAllDay: Bool
    var location: String?
    var reminderMinutes: Int?
    var recurrence: EventRecurrence?
    var assignedTo: User?
    let createdBy: User
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Event Request/Response Models

struct GetEventsResponse: Codable {
    let events: [Event]
}

struct CreateEventRequest: Codable {
    let title: String
    let description: String?
    let startDate: Date
    let endDate: Date?
    let isAllDay: Bool
    let location: String?
    let reminderMinutes: Int?
    let recurrence: EventRecurrence?
    let assignedToUserId: String?
}

struct CreateEventResponse: Codable {
    let event: Event
}

struct GetEventResponse: Codable {
    let event: Event
}

struct UpdateEventRequest: Codable {
    let title: String?
    let description: String?
    let startDate: Date?
    let endDate: Date?
    let isAllDay: Bool?
    let location: String?
    let reminderMinutes: Int?
    let recurrence: EventRecurrence?
    let assignedToUserId: String?
}

struct UpdateEventResponse: Codable {
    let event: Event
}
