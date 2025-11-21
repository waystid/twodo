import Foundation
import SwiftUI

@MainActor
class RoutineViewModel: ObservableObject {
    @Published var routines: [Routine] = []
    @Published var selectedRoutine: Routine?
    @Published var occurrences: [RoutineOccurrence] = []
    @Published var stats: RoutineStats?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Fetch Routines
    func fetchRoutines() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetRoutinesResponse = try await apiClient.request(.getRoutines)
            routines = response.routines
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Fetch Routine Detail
    func fetchRoutineDetail(routineId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetRoutineResponse = try await apiClient.request(.getRoutine(routineId))
            selectedRoutine = response.routine
            occurrences = response.occurrences
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Fetch Stats
    func fetchStats(for routineId: String) async {
        do {
            let response: GetRoutineStatsResponse = try await apiClient.request(.getRoutineStats(routineId))
            stats = response.stats
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Routine
    func createRoutine(
        name: String,
        description: String?,
        schedule: RoutineSchedule,
        assignedToUserId: String? = nil
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateRoutineRequest(
                name: name,
                description: description,
                schedule: schedule,
                assignedToUserId: assignedToUserId
            )
            let response: CreateRoutineResponse = try await apiClient.request(.createRoutine, body: request)
            routines.append(response.routine)
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Update Routine
    func updateRoutine(
        routineId: String,
        name: String?,
        description: String?,
        schedule: RoutineSchedule?,
        assignedToUserId: String?
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateRoutineRequest(
                name: name,
                description: description,
                schedule: schedule,
                assignedToUserId: assignedToUserId
            )
            let response: UpdateRoutineResponse = try await apiClient.request(
                .updateRoutine(routineId),
                body: request
            )

            if let index = routines.firstIndex(where: { $0.id == routineId }) {
                routines[index] = response.routine
            }
            selectedRoutine = response.routine

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Routine
    func deleteRoutine(routineId: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteRoutine(routineId))
            routines.removeAll { $0.id == routineId }
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Complete Occurrence
    func completeOccurrence(routineId: String, occurrenceId: String) async {
        // Optimistic update
        if let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) {
            var updated = occurrences[index]
            updated.completedAt = Date()
            occurrences[index] = updated
        }

        do {
            let response: CompleteOccurrenceResponse = try await apiClient.request(
                .completeOccurrence(routineId, occurrenceId)
            )

            // Update with server response
            if let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) {
                occurrences[index] = response.occurrence
            }

            // Refresh stats
            await fetchStats(for: routineId)
        } catch {
            // Revert optimistic update
            if let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) {
                var reverted = occurrences[index]
                reverted.completedAt = nil
                occurrences[index] = reverted
            }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Skip Occurrence
    func skipOccurrence(routineId: String, occurrenceId: String) async {
        // Optimistic update
        if let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) {
            var updated = occurrences[index]
            updated.skipped = true
            occurrences[index] = updated
        }

        do {
            let response: SkipOccurrenceResponse = try await apiClient.request(
                .skipOccurrence(routineId, occurrenceId)
            )

            // Update with server response
            if let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) {
                occurrences[index] = response.occurrence
            }

            // Refresh stats
            await fetchStats(for: routineId)
        } catch {
            // Revert optimistic update
            if let index = occurrences.firstIndex(where: { $0.id == occurrenceId }) {
                var reverted = occurrences[index]
                reverted.skipped = false
                occurrences[index] = reverted
            }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helper: Get Today's Occurrences
    var todaysOccurrences: [RoutineOccurrence] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return occurrences.filter { occurrence in
            calendar.isDate(occurrence.scheduledDate, inSameDayAs: today)
        }
    }

    // MARK: - Helper: Get Routines with Today's Occurrences
    func routinesWithTodaysStatus() -> [(routine: Routine, isDueToday: Bool, isCompleted: Bool)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return routines.map { routine in
            let isDue = routine.schedule.isDueOn(today)
            // Would need to fetch occurrences to check completion
            // For now, just return isDue status
            return (routine: routine, isDueToday: isDue, isCompleted: false)
        }
    }
}
