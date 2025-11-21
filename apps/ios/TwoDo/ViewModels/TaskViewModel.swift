import Foundation
import SwiftUI

@MainActor
class TaskViewModel: ObservableObject {
    @Published var taskLists: [TaskList] = []
    @Published var tasks: [Task] = []
    @Published var selectedList: TaskList?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Fetch Task Lists
    func fetchTaskLists() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetTaskListsResponse = try await apiClient.request(.getTaskLists)
            taskLists = response.lists
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Task List
    func createTaskList(name: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateTaskListRequest(name: name)
            let response: CreateTaskListResponse = try await apiClient.request(.createTaskList, body: request)
            taskLists.append(response.list)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Fetch Tasks for List
    func fetchTasks(for listId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetTasksResponse = try await apiClient.request(.getTasks(listId))
            tasks = response.tasks
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Task
    func createTask(
        listId: String,
        title: String,
        description: String? = nil,
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        assignedToUserId: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateTaskRequest(
                listId: listId,
                title: title,
                description: description,
                dueDate: dueDate,
                priority: priority,
                assignedToUserId: assignedToUserId
            )
            let response: CreateTaskResponse = try await apiClient.request(.createTask, body: request)
            tasks.append(response.task)
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update Task
    func updateTask(
        taskId: String,
        title: String? = nil,
        description: String? = nil,
        status: TaskStatus? = nil,
        priority: TaskPriority? = nil,
        dueDate: Date? = nil,
        assignedToUserId: String? = nil
    ) async {
        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateTaskRequest(
                title: title,
                description: description,
                status: status,
                priority: priority,
                dueDate: dueDate,
                assignedToUserId: assignedToUserId
            )
            let response: UpdateTaskResponse = try await apiClient.request(
                .updateTask(taskId),
                body: request
            )

            // Update local task
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index] = response.task
            }

            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Toggle Task Completion
    func toggleTaskCompletion(taskId: String) async {
        guard let task = tasks.first(where: { $0.id == taskId }) else { return }

        let completed = task.status != .completed

        // Optimistic update
        if let index = tasks.firstIndex(where: { $0.id == taskId }) {
            var updatedTask = tasks[index]
            updatedTask.status = completed ? .completed : .pending
            updatedTask.completedAt = completed ? Date() : nil
            tasks[index] = updatedTask
        }

        do {
            let request = CompleteTaskRequest(completed: completed)
            let response: CompleteTaskResponse = try await apiClient.request(
                .completeTask(taskId),
                body: request
            )

            // Update with server response
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                tasks[index] = response.task
            }
        } catch {
            // Revert optimistic update on error
            if let index = tasks.firstIndex(where: { $0.id == taskId }) {
                var revertedTask = tasks[index]
                revertedTask.status = task.status
                revertedTask.completedAt = task.completedAt
                tasks[index] = revertedTask
            }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Delete Task
    func deleteTask(taskId: String) async {
        isLoading = true
        errorMessage = nil

        do {
            let _: EmptyResponse = try await apiClient.request(.deleteTask(taskId))
            tasks.removeAll { $0.id == taskId }
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Helper: Get Tasks by Status
    func tasksByStatus(_ status: TaskStatus) -> [Task] {
        tasks.filter { $0.status == status }
    }

    // MARK: - Helper: Get Overdue Tasks
    var overdueTasks: [Task] {
        let now = Date()
        return tasks.filter { task in
            guard let dueDate = task.dueDate else { return false }
            return dueDate < now && task.status != .completed
        }
    }
}
