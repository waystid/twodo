import SwiftUI

struct TaskListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var taskViewModel = TaskViewModel()
    @StateObject private var coupleViewModel = CoupleViewModel()

    @State private var showNewTaskSheet = false
    @State private var showNewListSheet = false
    @State private var selectedTask: Task?

    var body: some View {
        NavigationStack {
            HStack(spacing: 0) {
                // Sidebar
                TaskListSidebar(
                    taskLists: taskViewModel.taskLists,
                    selectedList: $taskViewModel.selectedList,
                    onCreateList: { showNewListSheet = true }
                )
                .frame(width: 250)

                // Main content
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        VStack(alignment: .leading) {
                            Text(taskViewModel.selectedList?.name ?? "All Tasks")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(taskViewModel.tasks.count) tasks")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        // Add task button
                        Button {
                            showNewTaskSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.blue)
                        }
                        .disabled(taskViewModel.selectedList == nil)
                    }
                    .padding()
                    .background(Color(.systemBackground))

                    Divider()

                    // Task list
                    if taskViewModel.tasks.isEmpty {
                        EmptyTasksView()
                    } else {
                        List {
                            ForEach(taskViewModel.tasks) { task in
                                TaskRowView(
                                    task: task,
                                    onToggle: {
                                        Task {
                                            await taskViewModel.toggleTaskCompletion(taskId: task.id)
                                        }
                                    },
                                    onTap: {
                                        selectedTask = task
                                    }
                                )
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button(role: .destructive) {
                                        Task {
                                            await taskViewModel.deleteTask(taskId: task.id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(.plain)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            authViewModel.logout()
                        } label: {
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
            .sheet(isPresented: $showNewTaskSheet) {
                if let listId = taskViewModel.selectedList?.id {
                    NewTaskSheet(
                        listId: listId,
                        taskViewModel: taskViewModel
                    )
                }
            }
            .sheet(isPresented: $showNewListSheet) {
                NewListSheet(taskViewModel: taskViewModel)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task, taskViewModel: taskViewModel)
            }
            .task {
                await taskViewModel.fetchTaskLists()
                if let firstList = taskViewModel.taskLists.first {
                    taskViewModel.selectedList = firstList
                    await taskViewModel.fetchTasks(for: firstList.id)
                }
            }
        }
    }
}

// MARK: - Task List Sidebar
struct TaskListSidebar: View {
    let taskLists: [TaskList]
    @Binding var selectedList: TaskList?
    let onCreateList: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Text("Lists")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    onCreateList()
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                }
            }
            .padding()

            Divider()

            // Lists
            ScrollView {
                VStack(spacing: 4) {
                    ForEach(taskLists) { list in
                        Button {
                            selectedList = list
                        } label: {
                            HStack {
                                Image(systemName: "list.bullet")
                                Text(list.name)
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(selectedList?.id == list.id ? Color.blue.opacity(0.1) : Color.clear)
                            .foregroundStyle(selectedList?.id == list.id ? .blue : .primary)
                            .cornerRadius(8)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(8)
            }

            Spacer()
        }
        .background(Color(.secondarySystemBackground))
    }
}

// MARK: - Empty State
struct EmptyTasksView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No tasks yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Create a task to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TaskListView()
        .environmentObject(AuthViewModel())
}
