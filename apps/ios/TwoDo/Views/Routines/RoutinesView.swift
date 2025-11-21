import SwiftUI

struct RoutinesView: View {
    @StateObject private var viewModel = RoutineViewModel()
    @State private var showNewRoutineSheet = false
    @State private var selectedRoutine: Routine?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    if viewModel.routines.isEmpty {
                        EmptyRoutinesView()
                    } else {
                        ForEach(viewModel.routines) { routine in
                            RoutineCard(routine: routine) {
                                selectedRoutine = routine
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Routines")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showNewRoutineSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewRoutineSheet) {
                NewRoutineSheet(viewModel: viewModel)
            }
            .sheet(item: $selectedRoutine) { routine in
                RoutineDetailView(routine: routine, viewModel: viewModel)
            }
            .task {
                await viewModel.fetchRoutines()
            }
            .refreshable {
                await viewModel.fetchRoutines()
            }
        }
    }
}

struct RoutineCard: View {
    let routine: Routine
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(routine.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(scheduleDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Streak indicator
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                        Text("0") // Will be populated with real streak
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                }

                // Stats
                HStack(spacing: 20) {
                    StatItem(label: "Streak", value: "0 days")
                    StatItem(label: "Completion", value: "0%")
                    StatItem(label: "Total", value: "0")
                }

                // Description
                if let description = routine.description {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }

    private var scheduleDescription: String {
        switch routine.schedule.frequency {
        case .daily:
            return "Daily"
        case .weekly:
            if let days = routine.schedule.daysOfWeek {
                let dayNames = days.map { dayName(for: $0) }.joined(separator: ", ")
                return "Weekly: \(dayNames)"
            }
            return "Weekly"
        case .monthly:
            if let day = routine.schedule.dayOfMonth {
                return "Monthly on day \(day)"
            }
            return "Monthly"
        }
    }

    private func dayName(for index: Int) -> String {
        let days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return days[safe: index] ?? ""
    }
}

struct StatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }
}

struct EmptyRoutinesView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "repeat.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Routines Yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Create a routine to build healthy habits together")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
}

// Helper extension for safe array access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    RoutinesView()
}
