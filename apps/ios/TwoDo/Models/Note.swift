import Foundation

// MARK: - Note
struct Note: Codable, Identifiable {
    let id: String
    let coupleId: String
    var noteType: NoteType
    var entityType: String?
    var entityId: String?
    var title: String
    var content: String
    var tags: [String]?
    var isPrivate: Bool
    var sharedWithPartner: Bool
    let createdById: String
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Note Type
enum NoteType: String, Codable, CaseIterable {
    case general = "general"
    case journal = "journal"
    case taskNote = "task_note"
    case routineNote = "routine_note"
    case eventNote = "event_note"
    case shared = "shared"

    var displayName: String {
        switch self {
        case .general: return "General Note"
        case .journal: return "Journal Entry"
        case .taskNote: return "Task Note"
        case .routineNote: return "Routine Note"
        case .eventNote: return "Event Note"
        case .shared: return "Shared Note"
        }
    }

    var icon: String {
        switch self {
        case .general: return "note.text"
        case .journal: return "book.fill"
        case .taskNote: return "checkmark.circle"
        case .routineNote: return "repeat.circle"
        case .eventNote: return "calendar.circle"
        case .shared: return "person.2.fill"
        }
    }

    var color: String {
        switch self {
        case .general: return "blue"
        case .journal: return "purple"
        case .taskNote: return "green"
        case .routineNote: return "orange"
        case .eventNote: return "red"
        case .shared: return "pink"
        }
    }
}

// MARK: - Journal Entry
struct JournalEntry: Codable, Identifiable {
    let id: String
    let coupleId: String
    var date: Date
    var mood: Mood?
    var title: String?
    var content: String
    var gratitude: [String]?
    var highlights: [String]?
    var challenges: [String]?
    var tags: [String]?
    var isShared: Bool
    let createdById: String
    let createdAt: Date
    let updatedAt: Date

    var displayTitle: String {
        if let title = title, !title.isEmpty {
            return title
        }
        return "Journal Entry"
    }
}

// MARK: - Mood
enum Mood: String, Codable, CaseIterable {
    case amazing = "amazing"
    case good = "good"
    case okay = "okay"
    case bad = "bad"
    case terrible = "terrible"

    var emoji: String {
        switch self {
        case .amazing: return "😄"
        case .good: return "🙂"
        case .okay: return "😐"
        case .bad: return "😞"
        case .terrible: return "😢"
        }
    }

    var displayName: String {
        switch self {
        case .amazing: return "Amazing"
        case .good: return "Good"
        case .okay: return "Okay"
        case .bad: return "Bad"
        case .terrible: return "Terrible"
        }
    }

    var color: String {
        switch self {
        case .amazing: return "green"
        case .good: return "blue"
        case .okay: return "yellow"
        case .bad: return "orange"
        case .terrible: return "red"
        }
    }
}

// MARK: - API Request/Response Models

struct GetNotesResponse: Codable {
    let notes: [Note]
}

struct CreateNoteRequest: Codable {
    var noteType: NoteType
    var entityType: String?
    var entityId: String?
    var title: String
    var content: String
    var tags: [String]?
    var isPrivate: Bool
    var sharedWithPartner: Bool
}

struct UpdateNoteRequest: Codable {
    var title: String?
    var content: String?
    var tags: [String]?
    var isPrivate: Bool?
    var sharedWithPartner: Bool?
}

struct CreateNoteResponse: Codable {
    let note: Note
}

struct UpdateNoteResponse: Codable {
    let note: Note
}

struct GetJournalEntriesResponse: Codable {
    let entries: [JournalEntry]
}

struct CreateJournalEntryRequest: Codable {
    var date: Date
    var mood: Mood?
    var title: String?
    var content: String
    var gratitude: [String]?
    var highlights: [String]?
    var challenges: [String]?
    var tags: [String]?
    var isShared: Bool
}

struct UpdateJournalEntryRequest: Codable {
    var date: Date?
    var mood: Mood?
    var title: String?
    var content: String?
    var gratitude: [String]?
    var highlights: [String]?
    var challenges: [String]?
    var tags: [String]?
    var isShared: Bool?
}

struct CreateJournalEntryResponse: Codable {
    let entry: JournalEntry
}

struct UpdateJournalEntryResponse: Codable {
    let entry: JournalEntry
}
