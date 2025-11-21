import SwiftUI

struct NewRoutineSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RoutineViewModel

    @State private var name = ""
    @State private var description = ""
    @State private var frequency: RoutineFrequency = .daily
    @State private var selectedDays: Set<Int> = []
    @State private var dayOfMonth = 1

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Routine Name", text: $name)
                        .font(.headline)

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Schedule") {
                    Picker("Frequency", selection: $frequency) {
                        Text("Daily").tag(RoutineFrequency.daily)
                        Text("Weekly").tag(RoutineFrequency.weekly)
                        Text("Monthly").tag(RoutineFrequency.monthly)
                    }
                    .pickerStyle(.segmented)

                    if frequency == .weekly {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Days of Week")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            DayOfWeekPicker(selectedDays: $selectedDays)
                        }
                    }

                    if frequency == .monthly {
                        Picker("Day of Month", selection: $dayOfMonth) {
                            ForEach(1...28, id: \.self) { day in
                                Text("\(day)").tag(day)
                            }
                        }
                    }
                }

                Section {
                    Text("Routines help you build consistent habits together")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New Routine")
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
                            let success = await viewModel.createRoutine(
                                name: name,
                                description: description.isEmpty ? nil : description,
                                schedule: buildSchedule()
                            )
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var isValid: Bool {
        !name.isEmpty &&
        (frequency != .weekly || !selectedDays.isEmpty)
    }

    private func buildSchedule() -> RoutineSchedule {
        RoutineSchedule(
            frequency: frequency,
            daysOfWeek: frequency == .weekly ? Array(selectedDays).sorted() : nil,
            dayOfMonth: frequency == .monthly ? dayOfMonth : nil
        )
    }
}

struct DayOfWeekPicker: View {
    @Binding var selectedDays: Set<Int>

    private let days = [
        (0, "S"), (1, "M"), (2, "T"), (3, "W"), (4, "T"), (5, "F"), (6, "S")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.0) { index, label in
                Button {
                    if selectedDays.contains(index) {
                        selectedDays.remove(index)
                    } else {
                        selectedDays.insert(index)
                    }
                } label: {
                    Text(label)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .frame(width: 36, height: 36)
                        .background(selectedDays.contains(index) ? Color.blue : Color(.systemGray5))
                        .foregroundStyle(selectedDays.contains(index) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NewRoutineSheet(viewModel: RoutineViewModel())
}
