import SwiftUI

struct NewTaskSheet: View {
    @Environment(\.dismiss) var dismiss
    let listId: String
    @ObservedObject var taskViewModel: TaskViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var priority: TaskPriority = .medium
    @State private var dueDate = Date()
    @State private var hasDueDate = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Title", text: $title)
                        .font(.headline)

                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Priority") {
                    Picker("Priority", selection: $priority) {
                        Label("Low", systemImage: "circle.fill")
                            .tag(TaskPriority.low)
                        Label("Medium", systemImage: "circle.fill")
                            .tag(TaskPriority.medium)
                        Label("High", systemImage: "circle.fill")
                            .tag(TaskPriority.high)
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Toggle("Add Due Date", isOn: $hasDueDate)

                    if hasDueDate {
                        DatePicker(
                            "Due Date",
                            selection: $dueDate,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }
                }
            }
            .navigationTitle("New Task")
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
                            await taskViewModel.createTask(
                                listId: listId,
                                title: title,
                                description: description.isEmpty ? nil : description,
                                dueDate: hasDueDate ? dueDate : nil,
                                priority: priority
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct NewListSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var taskViewModel: TaskViewModel

    @State private var listName = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("List Name", text: $listName)
                        .font(.headline)
                }

                Section {
                    Text("Create a new list to organize your tasks")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("New List")
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
                            await taskViewModel.createTaskList(name: listName)
                            dismiss()
                        }
                    }
                    .disabled(listName.isEmpty)
                }
            }
        }
    }
}
