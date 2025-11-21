import SwiftUI

struct TaskDetailView: View {
    @Environment(\.dismiss) var dismiss
    let task: Task
    @ObservedObject var taskViewModel: TaskViewModel

    @State private var title: String
    @State private var description: String
    @State private var priority: TaskPriority
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @State private var isEditing = false

    init(task: Task, taskViewModel: TaskViewModel) {
        self.task = task
        self.taskViewModel = taskViewModel
        _title = State(initialValue: task.title)
        _description = State(initialValue: task.description ?? "")
        _priority = State(initialValue: task.priority)
        _dueDate = State(initialValue: task.dueDate ?? Date())
        _hasDueDate = State(initialValue: task.dueDate != nil)
    }

    var body: some View {
        NavigationStack {
            Form {
                // Status
                Section {
                    HStack {
                        Text("Status")
                            .foregroundStyle(.secondary)
                        Spacer()
                        StatusBadge(status: task.status)
                    }

                    Button {
                        Task {
                            await taskViewModel.toggleTaskCompletion(taskId: task.id)
                        }
                    } label: {
                        HStack {
                            Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                            Text(task.status == .completed ? "Mark as Incomplete" : "Mark as Complete")
                        }
                    }
                }

                // Details
                Section("Details") {
                    if isEditing {
                        TextField("Title", text: $title)
                        TextField("Description", text: $description, axis: .vertical)
                            .lineLimit(3...8)
                    } else {
                        LabeledContent("Title") {
                            Text(task.title)
                        }

                        if let desc = task.description {
                            LabeledContent("Description") {
                                Text(desc)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    if isEditing {
                        Picker("Priority", selection: $priority) {
                            Text("Low").tag(TaskPriority.low)
                            Text("Medium").tag(TaskPriority.medium)
                            Text("High").tag(TaskPriority.high)
                        }
                    } else {
                        LabeledContent("Priority") {
                            PriorityBadge(priority: task.priority)
                        }
                    }

                    if isEditing {
                        Toggle("Due Date", isOn: $hasDueDate)

                        if hasDueDate {
                            DatePicker(
                                "Date",
                                selection: $dueDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                    } else {
                        LabeledContent("Due Date") {
                            if let dueDate = task.dueDate {
                                Text(dueDate, style: .date)
                            } else {
                                Text("None")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                // Metadata
                Section("Info") {
                    LabeledContent("Created") {
                        Text(task.createdAt, style: .date)
                    }

                    if let completedAt = task.completedAt {
                        LabeledContent("Completed") {
                            Text(completedAt, style: .date)
                        }
                    }
                }

                // Delete
                if !isEditing {
                    Section {
                        Button(role: .destructive) {
                            Task {
                                await taskViewModel.deleteTask(taskId: task.id)
                                dismiss()
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Task")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Task Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    if isEditing {
                        Button("Save") {
                            Task {
                                await taskViewModel.updateTask(
                                    taskId: task.id,
                                    title: title,
                                    description: description.isEmpty ? nil : description,
                                    priority: priority,
                                    dueDate: hasDueDate ? dueDate : nil
                                )
                                isEditing = false
                            }
                        }
                    } else {
                        Button("Edit") {
                            isEditing = true
                        }
                    }
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: TaskStatus

    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.2))
            .foregroundStyle(statusColor)
            .cornerRadius(8)
    }

    private var statusText: String {
        switch status {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }

    private var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .inProgress: return .blue
        case .completed: return .green
        }
    }
}
