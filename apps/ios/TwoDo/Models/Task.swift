import Foundation

enum TaskStatus: String, Codable {
    case pending
    case inProgress = "in_progress"
    case completed
}

enum TaskPriority: String, Codable {
    case low
    case medium
    case high

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "orange"
        case .high: return "red"
        }
    }
}

struct TaskList: Codable, Identifiable {
    let id: String
    let coupleId: String
    var name: String
    var sortOrder: Int
    let createdById: String
    let createdAt: Date
    let updatedAt: Date
}

struct Task: Codable, Identifiable {
    let id: String
    let listId: String
    var title: String
    var description: String?
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date?
    var assignedToUserId: String?
    var completedAt: Date?
    var completedById: String?
    let createdById: String
    let createdAt: Date
    let updatedAt: Date
}

struct TaskWithDetails: Codable, Identifiable {
    let id: String
    let listId: String
    var title: String
    var description: String?
    var status: TaskStatus
    var priority: TaskPriority
    var dueDate: Date?
    var assignedTo: User?
    var completedAt: Date?
    var completedBy: User?
    let createdBy: User
    let createdAt: Date
    let updatedAt: Date
}

// MARK: - Task Request/Response Models

struct GetTaskListsResponse: Codable {
    let lists: [TaskList]
}

struct CreateTaskListRequest: Codable {
    let name: String
}

struct CreateTaskListResponse: Codable {
    let list: TaskList
}

struct GetTasksResponse: Codable {
    let tasks: [Task]
}

struct CreateTaskRequest: Codable {
    let listId: String
    let title: String
    let description: String?
    let dueDate: Date?
    let priority: TaskPriority
    let assignedToUserId: String?
}

struct CreateTaskResponse: Codable {
    let task: Task
}

struct UpdateTaskRequest: Codable {
    let title: String?
    let description: String?
    let status: TaskStatus?
    let priority: TaskPriority?
    let dueDate: Date?
    let assignedToUserId: String?
}

struct UpdateTaskResponse: Codable {
    let task: Task
}

struct CompleteTaskRequest: Codable {
    let completed: Bool
}

struct CompleteTaskResponse: Codable {
    let task: Task
}

struct AssignTaskRequest: Codable {
    let userId: String?
}

struct AssignTaskResponse: Codable {
    let task: Task
}
