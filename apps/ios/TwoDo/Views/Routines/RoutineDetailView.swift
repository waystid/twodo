import SwiftUI

struct RoutineDetailView: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutineViewModel
    @Environment(\.dismiss) var dismiss

    @State private var selectedTab = 0
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Tab Picker
                Picker("View", selection: $selectedTab) {
                    Text("Overview").tag(0)
                    Text("History").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Tab Content
                TabView(selection: $selectedTab) {
                    OverviewTab(routine: routine, viewModel: viewModel)
                        .tag(0)

                    HistoryTab(routine: routine, viewModel: viewModel)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .navigationTitle(routine.name)
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
                EditRoutineSheet(routine: routine, viewModel: viewModel)
            }
            .alert("Delete Routine", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteRoutine(routineId: routine.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this routine? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Overview Tab
struct OverviewTab: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Stats Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("Current Streak")
                            .font(.headline)
                    }

                    Text("\(routine.stats?.currentStreak ?? 0) days")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(.orange)

                    Divider()

                    HStack(spacing: 32) {
                        StatColumn(
                            label: "Longest Streak",
                            value: "\(routine.stats?.longestStreak ?? 0) days"
                        )

                        StatColumn(
                            label: "Completion Rate",
                            value: String(format: "%.0f%%", (routine.stats?.completionRate ?? 0) * 100)
                        )

                        StatColumn(
                            label: "Total Completed",
                            value: "\(routine.stats?.totalCompleted ?? 0)"
                        )
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Schedule Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "calendar")
                        Text("Schedule")
                            .font(.headline)
                    }

                    Text(scheduleDescription)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

                // Description Card
                if let description = routine.description, !description.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "text.alignleft")
                            Text("Description")
                                .font(.headline)
                        }

                        Text(description)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }

                // Today's Occurrence
                if let todaysOccurrence = viewModel.todaysOccurrences.first(where: { $0.routineId == routine.id }) {
                    TodaysOccurrenceCard(
                        occurrence: todaysOccurrence,
                        viewModel: viewModel
                    )
                }
            }
            .padding()
        }
    }

    private var scheduleDescription: String {
        let schedule = routine.schedule
        switch schedule.frequency {
        case .daily:
            return "Every day"
        case .weekly:
            if let days = schedule.daysOfWeek, !days.isEmpty {
                let dayNames = days.map { dayName(for: $0) }.joined(separator: ", ")
                return "Every \(dayNames)"
            }
            return "Weekly"
        case .monthly:
            if let day = schedule.dayOfMonth {
                return "Day \(day) of every month"
            }
            return "Monthly"
        }
    }

    private func dayName(for index: Int) -> String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[safe: index] ?? ""
    }
}

// MARK: - History Tab
struct HistoryTab: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Last 30 Days")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top)

                if viewModel.occurrences.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No history yet")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                } else {
                    LazyVStack(spacing: 8) {
                        ForEach(routineOccurrences) { occurrence in
                            OccurrenceRow(occurrence: occurrence, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .task {
            await viewModel.fetchOccurrences(
                routineId: routine.id,
                start: Calendar.current.date(byAdding: .day, value: -30, to: Date()),
                end: Date()
            )
        }
    }

    private var routineOccurrences: [RoutineOccurrence] {
        viewModel.occurrences
            .filter { $0.routineId == routine.id }
            .sorted { $0.scheduledDate > $1.scheduledDate }
    }
}

// MARK: - Supporting Views

struct StatColumn: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline)
        }
    }
}

struct TodaysOccurrenceCard: View {
    let occurrence: RoutineOccurrence
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                Text("Today's Routine")
                    .font(.headline)
            }

            if occurrence.completedAt == nil && occurrence.skippedAt == nil {
                HStack(spacing: 12) {
                    Button {
                        Task {
                            await viewModel.completeOccurrence(
                                routineId: occurrence.routineId,
                                occurrenceId: occurrence.id
                            )
                        }
                    } label: {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Complete")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }

                    Button {
                        Task {
                            await viewModel.skipOccurrence(
                                routineId: occurrence.routineId,
                                occurrenceId: occurrence.id
                            )
                        }
                    } label: {
                        HStack {
                            Image(systemName: "forward")
                            Text("Skip")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(.systemGray5))
                        .foregroundStyle(.primary)
                        .cornerRadius(8)
                    }
                }
            } else if occurrence.completedAt != nil {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Completed")
                        .foregroundStyle(.secondary)
                    Spacer()
                    if let completedAt = occurrence.completedAt {
                        Text(completedAt, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                HStack {
                    Image(systemName: "forward.circle.fill")
                        .foregroundStyle(.orange)
                    Text("Skipped")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct OccurrenceRow: View {
    let occurrence: RoutineOccurrence
    @ObservedObject var viewModel: RoutineViewModel

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(occurrence.scheduledDate, style: .date)
                    .font(.body)

                if let completedAt = occurrence.completedAt {
                    Text("Completed at \(completedAt, style: .time)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if occurrence.skippedAt != nil {
                    Text("Skipped")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if occurrence.scheduledDate < Date() {
                    Text("Missed")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Text("Scheduled")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Status Icon
            if occurrence.completedAt != nil {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            } else if occurrence.skippedAt != nil {
                Image(systemName: "forward.circle.fill")
                    .foregroundStyle(.orange)
            } else if occurrence.scheduledDate < Date() {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
            } else {
                Image(systemName: "circle")
                    .foregroundStyle(.gray)
            }

            // Action button for incomplete past occurrences
            if occurrence.completedAt == nil && occurrence.skippedAt == nil && occurrence.scheduledDate < Date() {
                Button {
                    Task {
                        await viewModel.completeOccurrence(
                            routineId: occurrence.routineId,
                            occurrenceId: occurrence.id
                        )
                    }
                } label: {
                    Text("Complete")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .foregroundStyle(.white)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}

// MARK: - Edit Routine Sheet
struct EditRoutineSheet: View {
    let routine: Routine
    @ObservedObject var viewModel: RoutineViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var description: String
    @State private var frequency: RoutineFrequency
    @State private var selectedDays: Set<Int>
    @State private var dayOfMonth: Int

    init(routine: Routine, viewModel: RoutineViewModel) {
        self.routine = routine
        self.viewModel = viewModel
        _name = State(initialValue: routine.name)
        _description = State(initialValue: routine.description ?? "")
        _frequency = State(initialValue: routine.schedule.frequency)
        _selectedDays = State(initialValue: Set(routine.schedule.daysOfWeek ?? []))
        _dayOfMonth = State(initialValue: routine.schedule.dayOfMonth ?? 1)
    }

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
            }
            .navigationTitle("Edit Routine")
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
                            await viewModel.updateRoutine(
                                routineId: routine.id,
                                name: name.isEmpty ? nil : name,
                                description: description.isEmpty ? nil : description,
                                schedule: buildSchedule()
                            )
                            dismiss()
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

// MARK: - Helper Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    RoutineDetailView(
        routine: Routine(
            id: "1",
            coupleId: "1",
            name: "Morning Exercise",
            description: "30 minutes of exercise to start the day",
            schedule: RoutineSchedule(
                frequency: .daily,
                daysOfWeek: nil,
                dayOfMonth: nil
            ),
            isActive: true,
            stats: RoutineStats(
                currentStreak: 5,
                longestStreak: 10,
                totalCompleted: 45,
                completionRate: 0.85
            ),
            createdById: "1",
            createdAt: Date(),
            updatedAt: Date()
        ),
        viewModel: RoutineViewModel()
    )
}
