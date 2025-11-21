import SwiftUI

struct NewEventSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: CalendarViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(3600) // 1 hour later
    @State private var isAllDay = false
    @State private var location = ""
    @State private var hasReminder = false
    @State private var reminderMinutes = 15
    @State private var hasRecurrence = false
    @State private var recurrenceFrequency: RecurrenceFrequency = .daily
    @State private var recurrenceInterval = 1
    @State private var hasRecurrenceEnd = false
    @State private var recurrenceEndDate = Date().addingTimeInterval(86400 * 30) // 30 days

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
            .navigationTitle("New Event")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            let success = await viewModel.createEvent(
                                title: title,
                                description: description.isEmpty ? nil : description,
                                startDate: startDate,
                                endDate: isAllDay ? nil : endDate,
                                isAllDay: isAllDay,
                                location: location.isEmpty ? nil : location,
                                reminderMinutes: hasReminder ? reminderMinutes : nil,
                                recurrence: hasRecurrence ? buildRecurrence() : nil,
                                assignedToUserId: nil
                            )
                            if success {
                                dismiss()
                            }
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
    NewEventSheet(viewModel: CalendarViewModel())
}
