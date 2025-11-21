import SwiftUI

struct TaskRowView: View {
    let task: Task
    let onToggle: () -> Void
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                Button {
                    onToggle()
                } label: {
                    Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundStyle(task.status == .completed ? .green : .gray)
                }
                .buttonStyle(.plain)

                // Task content
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.body)
                        .strikethrough(task.status == .completed)
                        .foregroundStyle(task.status == .completed ? .secondary : .primary)

                    HStack(spacing: 8) {
                        // Priority badge
                        PriorityBadge(priority: task.priority)

                        // Due date
                        if let dueDate = task.dueDate {
                            HStack(spacing: 4) {
                                Image(systemName: "calendar")
                                    .font(.caption2)
                                Text(dueDate, style: .date)
                                    .font(.caption)
                            }
                            .foregroundStyle(isOverdue(dueDate) ? .red : .secondary)
                        }

                        // Assignment indicator
                        if task.assignedToUserId != nil {
                            Image(systemName: "person.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.blue)
                        }
                    }
                }

                Spacer()

                // Chevron
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private func isOverdue(_ date: Date) -> Bool {
        date < Date() && task.status != .completed
    }
}

struct PriorityBadge: View {
    let priority: TaskPriority

    var body: some View {
        HStack(spacing: 2) {
            Circle()
                .fill(priorityColor)
                .frame(width: 6, height: 6)

            Text(priority.rawValue.capitalized)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
    }

    private var priorityColor: Color {
        switch priority {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

#Preview {
    List {
        TaskRowView(
            task: Task(
                id: "1",
                listId: "1",
                title: "Sample Task",
                description: "This is a sample task",
                status: .pending,
                priority: .high,
                dueDate: Date(),
                assignedToUserId: nil,
                completedAt: nil,
                completedById: nil,
                createdById: "1",
                createdAt: Date(),
                updatedAt: Date()
            ),
            onToggle: {},
            onTap: {}
        )
    }
}
