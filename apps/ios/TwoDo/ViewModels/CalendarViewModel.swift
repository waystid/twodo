import Foundation
import SwiftUI

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var events: [Event] = []
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Date = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Fetch Events
    func fetchEvents(start: Date? = nil, end: Date? = nil) async {
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
            let response: GetEventsResponse = try await apiClient.request(
                .getEvents,
                queryItems: queryItems.isEmpty ? nil : queryItems
            )
            events = response.events
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Fetch Events for Month
    func fetchEventsForMonth(_ date: Date) async {
        let calendar = Calendar.current
        guard let range = calendar.dateInterval(of: .month, for: date) else { return }

        await fetchEvents(start: range.start, end: range.end)
    }

    // MARK: - Create Event
    func createEvent(
        title: String,
        description: String?,
        startDate: Date,
        endDate: Date?,
        isAllDay: Bool,
        location: String?,
        reminderMinutes: Int?,
        recurrence: EventRecurrence?,
        assignedToUserId: String?
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateEventRequest(
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                location: location,
                reminderMinutes: reminderMinutes,
                recurrence: recurrence,
                assignedToUserId: assignedToUserId
            )
            let response: CreateEventResponse = try await apiClient.request(.createEvent, body: request)
            events.append(response.event)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update Event
    func updateEvent(
        eventId: String,
        title: String?,
        description: String?,
        startDate: Date?,
        endDate: Date?,
        isAllDay: Bool?,
        location: String?,
        reminderMinutes: Int?,
        recurrence: EventRecurrence?,
        assignedToUserId: String?
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateEventRequest(
                title: title,
                description: description,
                startDate: startDate,
                endDate: endDate,
                isAllDay: isAllDay,
                location: location,
                reminderMinutes: reminderMinutes,
                recurrence: recurrence,
                assignedToUserId: assignedToUserId
            )
            let response: UpdateEventResponse = try await apiClient.request(
                .updateEvent(eventId),
                body: request
            )

            if let index = events.firstIndex(where: { $0.id == eventId }) {
                events[index] = response.event
            }

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Event
    func deleteEvent(eventId: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteEvent(eventId))
            events.removeAll { $0.id == eventId }
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Helper: Events for Specific Date
    func events(for date: Date) -> [Event] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.startDate, inSameDayAs: date)
        }
    }

    // MARK: - Helper: Has Events on Date
    func hasEvents(on date: Date) -> Bool {
        !events(for: date).isEmpty
    }

    // MARK: - Calendar Helpers
    func daysInMonth(for date: Date) -> [Date?] {
        let calendar = Calendar.current
        guard let range = calendar.range(of: .day, in: .month, for: date),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date))
        else {
            return []
        }

        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        var days: [Date?] = []

        // Add empty days for padding
        for _ in 1..<firstWeekday {
            days.append(nil)
        }

        // Add days of month
        for day in range {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) {
                days.append(date)
            }
        }

        return days
    }

    func moveToNextMonth() {
        let calendar = Calendar.current
        if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            currentMonth = nextMonth
        }
    }

    func moveToPreviousMonth() {
        let calendar = Calendar.current
        if let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = previousMonth
        }
    }

    func moveToToday() {
        currentMonth = Date()
        selectedDate = Date()
    }
}
