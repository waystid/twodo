import SwiftUI

struct EventDetailView: View {
    let event: Event
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    VStack(alignment: .leading, spacing: 8) {
                        Text(event.title)
                            .font(.title2)
                            .fontWeight(.bold)

                        if let description = event.description, !description.isEmpty {
                            Text(description)
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    // Date & Time
                    DetailRow(
                        icon: "calendar",
                        label: "Date",
                        value: formatDateRange()
                    )

                    if !event.isAllDay {
                        DetailRow(
                            icon: "clock",
                            label: "Time",
                            value: formatTimeRange()
                        )
                    }

                    // Location
                    if let location = event.location, !location.isEmpty {
                        Divider()

                        DetailRow(
                            icon: "location.fill",
                            label: "Location",
                            value: location
                        )
                    }

                    // Reminder
                    if let reminderMinutes = event.reminderMinutes {
                        Divider()

                        DetailRow(
                            icon: "bell.fill",
                            label: "Reminder",
                            value: formatReminder(reminderMinutes)
                        )
                    }

                    // Recurrence
                    if let recurrence = event.recurrence {
                        Divider()

                        DetailRow(
                            icon: "repeat",
                            label: "Repeat",
                            value: formatRecurrence(recurrence)
                        )
                    }

                    // Assignment
                    if event.assignedToUserId != nil {
                        Divider()

                        DetailRow(
                            icon: "person.circle.fill",
                            label: "Assigned to",
                            value: "Partner"
                        )
                    }

                    // Metadata
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Created \(event.createdAt, style: .relative) ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if event.updatedAt != event.createdAt {
                            Text("Updated \(event.updatedAt, style: .relative) ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showEditSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }

                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditEventSheet(event: event, viewModel: viewModel)
            }
            .alert("Delete Event", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteEvent(eventId: event.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this event? This action cannot be undone.")
            }
        }
    }

    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none

        if let endDate = event.endDate, !Calendar.current.isDate(event.startDate, inSameDayAs: endDate) {
            return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: endDate))"
        } else {
            return formatter.string(from: event.startDate)
        }
    }

    private func formatTimeRange() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short

        if let endDate = event.endDate {
            return "\(formatter.string(from: event.startDate)) - \(formatter.string(from: endDate))"
        } else {
            return formatter.string(from: event.startDate)
        }
    }

    private func formatReminder(_ minutes: Int) -> String {
        switch minutes {
        case 5:
            return "5 minutes before"
        case 15:
            return "15 minutes before"
        case 30:
            return "30 minutes before"
        case 60:
            return "1 hour before"
        case 1440:
            return "1 day before"
        case 10080:
            return "1 week before"
        default:
            return "\(minutes) minutes before"
        }
    }

    private func formatRecurrence(_ recurrence: EventRecurrence) -> String {
        let frequencyText: String
        switch recurrence.frequency {
        case .daily:
            frequencyText = recurrence.interval == 1 ? "Daily" : "Every \(recurrence.interval) days"
        case .weekly:
            frequencyText = recurrence.interval == 1 ? "Weekly" : "Every \(recurrence.interval) weeks"
        case .monthly:
            frequencyText = recurrence.interval == 1 ? "Monthly" : "Every \(recurrence.interval) months"
        case .yearly:
            frequencyText = recurrence.interval == 1 ? "Yearly" : "Every \(recurrence.interval) years"
        }

        if let until = recurrence.until {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "\(frequencyText), until \(formatter.string(from: until))"
        } else {
            return frequencyText
        }
    }
}

// MARK: - Detail Row
struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
    }
}

// MARK: - Edit Event Sheet
struct EditEventSheet: View {
    let event: Event
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var description: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var isAllDay: Bool
    @State private var location: String
    @State private var hasReminder: Bool
    @State private var reminderMinutes: Int
    @State private var hasRecurrence: Bool
    @State private var recurrenceFrequency: RecurrenceFrequency
    @State private var recurrenceInterval: Int
    @State private var hasRecurrenceEnd: Bool
    @State private var recurrenceEndDate: Date

    init(event: Event, viewModel: CalendarViewModel) {
        self.event = event
        self.viewModel = viewModel
        _title = State(initialValue: event.title)
        _description = State(initialValue: event.description ?? "")
        _startDate = State(initialValue: event.startDate)
        _endDate = State(initialValue: event.endDate ?? event.startDate.addingTimeInterval(3600))
        _isAllDay = State(initialValue: event.isAllDay)
        _location = State(initialValue: event.location ?? "")
        _hasReminder = State(initialValue: event.reminderMinutes != nil)
        _reminderMinutes = State(initialValue: event.reminderMinutes ?? 15)
        _hasRecurrence = State(initialValue: event.recurrence != nil)
        _recurrenceFrequency = State(initialValue: event.recurrence?.frequency ?? .daily)
        _recurrenceInterval = State(initialValue: event.recurrence?.interval ?? 1)
        _hasRecurrenceEnd = State(initialValue: event.recurrence?.until != nil)
        _recurrenceEndDate = State(initialValue: event.recurrence?.until ?? Date().addingTimeInterval(86400 * 30))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Title", text: $title)
                        .font(.headline)

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Date & Time") {
                    Toggle("All Day", isOn: $isAllDay)

                    DatePicker(
                        "Start",
                        selection: $startDate,
                        displayedComponents: isAllDay ? [.date] : [.date, .hourAndMinute]
                    )

                    if !isAllDay {
                        DatePicker(
                            "End",
                            selection: $endDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }

                Section("Location") {
                    TextField("Add location", text: $location)
                }

                Section("Reminder") {
                    Toggle("Remind me", isOn: $hasReminder)

                    if hasReminder {
                        Picker("Remind me before", selection: $reminderMinutes) {
                            Text("5 minutes").tag(5)
                            Text("15 minutes").tag(15)
                            Text("30 minutes").tag(30)
                            Text("1 hour").tag(60)
                            Text("1 day").tag(1440)
                            Text("1 week").tag(10080)
                        }
                    }
                }

                Section("Recurrence") {
                    Toggle("Repeat", isOn: $hasRecurrence)

                    if hasRecurrence {
                        Picker("Frequency", selection: $recurrenceFrequency) {
                            Text("Daily").tag(RecurrenceFrequency.daily)
                            Text("Weekly").tag(RecurrenceFrequency.weekly)
                            Text("Monthly").tag(RecurrenceFrequency.monthly)
                            Text("Yearly").tag(RecurrenceFrequency.yearly)
                        }

                        Stepper("Every \(recurrenceInterval) \(frequencyUnit)", value: $recurrenceInterval, in: 1...99)

                        Toggle("End date", isOn: $hasRecurrenceEnd)

                        if hasRecurrenceEnd {
                            DatePicker(
                                "Ends on",
                                selection: $recurrenceEndDate,
                                displayedComponents: [.date]
                            )
                        }
                    }
                }
            }
            .navigationTitle("Edit Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateEvent(
                                eventId: event.id,
                                title: title.isEmpty ? nil : title,
                                description: description.isEmpty ? nil : description,
                                startDate: startDate,
                                endDate: isAllDay ? nil : endDate,
                                isAllDay: isAllDay,
                                location: location.isEmpty ? nil : location,
                                reminderMinutes: hasReminder ? reminderMinutes : nil,
                                recurrence: hasRecurrence ? buildRecurrence() : nil,
                                assignedToUserId: nil
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private var frequencyUnit: String {
        let base: String
        switch recurrenceFrequency {
        case .daily:
            base = "day"
        case .weekly:
            base = "week"
        case .monthly:
            base = "month"
        case .yearly:
            base = "year"
        }
        return recurrenceInterval == 1 ? base : base + "s"
    }

    private func buildRecurrence() -> EventRecurrence {
        EventRecurrence(
            frequency: recurrenceFrequency,
            interval: recurrenceInterval,
            until: hasRecurrenceEnd ? recurrenceEndDate : nil
        )
    }
}

#Preview {
    EventDetailView(
        event: Event(
            id: "1",
            coupleId: "1",
            title: "Dinner Date",
            description: "Anniversary dinner at our favorite restaurant",
            startDate: Date(),
            endDate: Date().addingTimeInterval(7200),
            isAllDay: false,
            location: "Italian Restaurant",
            reminderMinutes: 60,
            recurrence: nil,
            assignedToUserId: nil,
            createdById: "1",
            createdAt: Date(),
            updatedAt: Date()
        ),
        viewModel: CalendarViewModel()
    )
}
