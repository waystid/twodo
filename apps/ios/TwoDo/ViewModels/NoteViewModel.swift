import Foundation
import SwiftUI

@MainActor
class NoteViewModel: ObservableObject {
    @Published var notes: [Note] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Fetch Notes
    func fetchNotes(type: NoteType? = nil, entityType: String? = nil, entityId: String? = nil) async {
        isLoading = true
        errorMessage = nil

        var queryItems: [URLQueryItem] = []
        if let type = type {
            queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
        }
        if let entityType = entityType {
            queryItems.append(URLQueryItem(name: "entityType", value: entityType))
        }
        if let entityId = entityId {
            queryItems.append(URLQueryItem(name: "entityId", value: entityId))
        }

        do {
            let response: GetNotesResponse = try await apiClient.request(
                .getNotes,
                queryItems: queryItems.isEmpty ? nil : queryItems
            )
            notes = response.notes
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Note
    func createNote(
        noteType: NoteType,
        entityType: String? = nil,
        entityId: String? = nil,
        title: String,
        content: String,
        tags: [String]? = nil,
        isPrivate: Bool = false,
        sharedWithPartner: Bool = false
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateNoteRequest(
                noteType: noteType,
                entityType: entityType,
                entityId: entityId,
                title: title,
                content: content,
                tags: tags,
                isPrivate: isPrivate,
                sharedWithPartner: sharedWithPartner
            )
            let response: CreateNoteResponse = try await apiClient.request(.createNote, body: request)
            notes.insert(response.note, at: 0)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update Note
    func updateNote(
        noteId: String,
        title: String? = nil,
        content: String? = nil,
        tags: [String]? = nil,
        isPrivate: Bool? = nil,
        sharedWithPartner: Bool? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateNoteRequest(
                title: title,
                content: content,
                tags: tags,
                isPrivate: isPrivate,
                sharedWithPartner: sharedWithPartner
            )
            let response: UpdateNoteResponse = try await apiClient.request(
                .updateNote(noteId),
                body: request
            )

            if let index = notes.firstIndex(where: { $0.id == noteId }) {
                notes[index] = response.note
            }

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Note
    func deleteNote(noteId: String) async -> Bool {
        // Optimistic update
        let originalNotes = notes
        notes.removeAll { $0.id == noteId }

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteNote(noteId))
            return true
        } catch {
            // Revert on error
            notes = originalNotes
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Fetch Journal Entries
    func fetchJournalEntries(start: Date? = nil, end: Date? = nil) async {
        isLoading = true
        errorMessage = nil

        var queryItems: [URLQueryItem] = []
        if let start = start {
            queryItems.append(URLQueryItem(name: "start", value: ISO8601DateFormatter().string(from: start)))
        }
        if let end = end {
            queryItems.append(URLQueryItem(name: "end", value: ISO8601DateFormatter().string(from: end)))
        }

        do {
            let response: GetJournalEntriesResponse = try await apiClient.request(
                .getJournalEntries,
                queryItems: queryItems.isEmpty ? nil : queryItems
            )
            journalEntries = response.entries
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Journal Entry
    func createJournalEntry(
        date: Date,
        mood: Mood? = nil,
        title: String? = nil,
        content: String,
        gratitude: [String]? = nil,
        highlights: [String]? = nil,
        challenges: [String]? = nil,
        tags: [String]? = nil,
        isShared: Bool = false
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateJournalEntryRequest(
                date: date,
                mood: mood,
                title: title,
                content: content,
                gratitude: gratitude,
                highlights: highlights,
                challenges: challenges,
                tags: tags,
                isShared: isShared
            )
            let response: CreateJournalEntryResponse = try await apiClient.request(.createJournalEntry, body: request)
            journalEntries.insert(response.entry, at: 0)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update Journal Entry
    func updateJournalEntry(
        entryId: String,
        date: Date? = nil,
        mood: Mood? = nil,
        title: String? = nil,
        content: String? = nil,
        gratitude: [String]? = nil,
        highlights: [String]? = nil,
        challenges: [String]? = nil,
        tags: [String]? = nil,
        isShared: Bool? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateJournalEntryRequest(
                date: date,
                mood: mood,
                title: title,
                content: content,
                gratitude: gratitude,
                highlights: highlights,
                challenges: challenges,
                tags: tags,
                isShared: isShared
            )
            let response: UpdateJournalEntryResponse = try await apiClient.request(
                .updateJournalEntry(entryId),
                body: request
            )

            if let index = journalEntries.firstIndex(where: { $0.id == entryId }) {
                journalEntries[index] = response.entry
            }

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Journal Entry
    func deleteJournalEntry(entryId: String) async -> Bool {
        // Optimistic update
        let originalEntries = journalEntries
        journalEntries.removeAll { $0.id == entryId }

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteJournalEntry(entryId))
            return true
        } catch {
            // Revert on error
            journalEntries = originalEntries
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Helper: Group Notes by Type
    func notesByType() -> [(NoteType, [Note])] {
        var groups: [NoteType: [Note]] = [:]

        for note in notes {
            if groups[note.noteType] == nil {
                groups[note.noteType] = []
            }
            groups[note.noteType]?.append(note)
        }

        return groups
            .sorted { $0.key.rawValue < $1.key.rawValue }
            .map { ($0.key, $0.value) }
    }

    // MARK: - Helper: Group Journal Entries by Month
    func journalEntriesByMonth() -> [(String, [JournalEntry])] {
        let calendar = Calendar.current
        var groups: [String: [JournalEntry]] = [:]

        for entry in journalEntries {
            let components = calendar.dateComponents([.year, .month], from: entry.date)
            if let date = calendar.date(from: components) {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                let key = formatter.string(from: date)

                if groups[key] == nil {
                    groups[key] = []
                }
                groups[key]?.append(entry)
            }
        }

        return groups
            .sorted { first, second in
                let formatter = DateFormatter()
                formatter.dateFormat = "MMMM yyyy"
                guard let date1 = formatter.date(from: first.key),
                      let date2 = formatter.date(from: second.key) else {
                    return false
                }
                return date1 > date2
            }
            .map { ($0.key, $0.value.sorted { $0.date > $1.date }) }
    }

    // MARK: - Helper: Get Entry for Date
    func getJournalEntry(for date: Date) -> JournalEntry? {
        let calendar = Calendar.current
        return journalEntries.first { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }

    // MARK: - Helper: Filter Notes
    func filterNotes(searchText: String) -> [Note] {
        guard !searchText.isEmpty else { return notes }

        return notes.filter { note in
            note.title.localizedCaseInsensitiveContains(searchText) ||
            note.content.localizedCaseInsensitiveContains(searchText) ||
            (note.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
        }
    }

    // MARK: - Helper: Filter Journal Entries
    func filterJournalEntries(searchText: String) -> [JournalEntry] {
        guard !searchText.isEmpty else { return journalEntries }

        return journalEntries.filter { entry in
            (entry.title?.localizedCaseInsensitiveContains(searchText) ?? false) ||
            entry.content.localizedCaseInsensitiveContains(searchText) ||
            (entry.tags?.contains { $0.localizedCaseInsensitiveContains(searchText) } ?? false)
        }
    }
}
