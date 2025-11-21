import SwiftUI

struct NotesView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var showNewNoteSheet = false
    @State private var selectedNote: Note?
    @State private var searchText = ""
    @State private var selectedType: NoteType?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Type Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        TypeFilterButton(
                            title: "All",
                            isSelected: selectedType == nil,
                            onTap: { selectedType = nil }
                        )

                        ForEach(NoteType.allCases, id: \.self) { type in
                            TypeFilterButton(
                                title: type.displayName,
                                icon: type.icon,
                                isSelected: selectedType == type,
                                onTap: { selectedType = type }
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(.systemBackground))

                Divider()

                // Notes List
                if viewModel.isLoading && viewModel.notes.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if filteredNotes.isEmpty {
                    EmptyNotesView(hasSearchText: !searchText.isEmpty)
                } else {
                    List {
                        ForEach(filteredNotes) { note in
                            NoteRowView(note: note, onTap: {
                                selectedNote = note
                            })
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        await viewModel.deleteNote(noteId: note.id)
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
            .navigationTitle("Notes")
            .searchable(text: $searchText, prompt: "Search notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewNoteSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewNoteSheet) {
                NewNoteSheet(viewModel: viewModel)
            }
            .sheet(item: $selectedNote) { note in
                NoteDetailView(note: note, viewModel: viewModel)
            }
            .refreshable {
                await viewModel.fetchNotes()
            }
            .task {
                await viewModel.fetchNotes()
            }
        }
    }

    private var filteredNotes: [Note] {
        var notes = viewModel.filterNotes(searchText: searchText)

        if let selectedType = selectedType {
            notes = notes.filter { $0.noteType == selectedType }
        }

        return notes.sorted { $0.updatedAt > $1.updatedAt }
    }
}

// MARK: - Type Filter Button
struct TypeFilterButton: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 6) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.subheadline)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundStyle(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Note Row
struct NoteRowView: View {
    let note: Note
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: note.noteType.icon)
                        .foregroundStyle(iconColor)
                    Text(note.title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Spacer()
                    if note.isPrivate {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    if note.sharedWithPartner {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }

                Text(note.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                HStack {
                    if let tags = note.tags, !tags.isEmpty {
                        HStack(spacing: 4) {
                            ForEach(tags.prefix(3), id: \.self) { tag in
                                Text("#\(tag)")
                                    .font(.caption2)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }

                    Spacer()

                    Text(note.updatedAt, style: .relative)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }

    private var iconColor: Color {
        switch note.noteType.color {
        case "blue": return .blue
        case "purple": return .purple
        case "green": return .green
        case "orange": return .orange
        case "red": return .red
        case "pink": return .pink
        default: return .gray
        }
    }
}

// MARK: - Empty State
struct EmptyNotesView: View {
    let hasSearchText: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: hasSearchText ? "magnifyingglass" : "note.text")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(hasSearchText ? "No notes found" : "No notes yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text(hasSearchText ? "Try a different search" : "Create a note to get started")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NotesView()
}
