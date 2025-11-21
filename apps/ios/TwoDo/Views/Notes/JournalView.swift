import SwiftUI

struct JournalView: View {
    @StateObject private var viewModel = NoteViewModel()
    @State private var selectedDate = Date()
    @State private var showNewEntrySheet = false
    @State private var selectedEntry: JournalEntry?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Date Picker
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.compact)
                .padding()
                .background(Color(.secondarySystemBackground))

                Divider()

                // Journal Entries List
                if viewModel.isLoading && viewModel.journalEntries.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.journalEntries.isEmpty {
                    EmptyJournalView()
                } else {
                    List {
                        ForEach(viewModel.journalEntriesByMonth(), id: \.0) { month, entries in
                            Section(month) {
                                ForEach(entries) { entry in
                                    JournalEntryRow(entry: entry, onTap: {
                                        selectedEntry = entry
                                    })
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            Task {
                                                await viewModel.deleteJournalEntry(entryId: entry.id)
                                            }
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewEntrySheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewEntrySheet) {
                NewJournalEntrySheet(viewModel: viewModel, date: selectedDate)
            }
            .sheet(item: $selectedEntry) { entry in
                JournalEntryDetailView(entry: entry, viewModel: viewModel)
            }
            .refreshable {
                await viewModel.fetchJournalEntries()
            }
            .task {
                await viewModel.fetchJournalEntries()
            }
        }
    }
}

// MARK: - Journal Entry Row
struct JournalEntryRow: View {
    let entry: JournalEntry
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    if let mood = entry.mood {
                        Text(mood.emoji)
                            .font(.title2)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.displayTitle)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if entry.isShared {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }

                Text(entry.content)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)

                if let highlights = entry.highlights, !highlights.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(highlights.count) highlight\(highlights.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - New Journal Entry Sheet
struct NewJournalEntrySheet: View {
    @ObservedObject var viewModel: NoteViewModel
    let date: Date
    @Environment(\.dismiss) var dismiss

    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Mood?
    @State private var gratitude: [String] = []
    @State private var gratitudeInput = ""
    @State private var highlights: [String] = []
    @State private var highlightInput = ""
    @State private var challenges: [String] = []
    @State private var challengeInput = ""
    @State private var isShared = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker("Date", selection: .constant(date), displayedComponents: [.date])
                        .disabled(true)

                    TextField("Title (optional)", text: $title)
                        .font(.headline)
                }

                Section("How are you feeling?") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(Mood.allCases, id: \.self) { mood in
                                MoodButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood,
                                    onTap: {
                                        selectedMood = mood
                                    }
                                )
                            }
                        }
                    }
                }

                Section("Journal Entry") {
                    TextField("What's on your mind?", text: $content, axis: .vertical)
                        .lineLimit(5...15)
                }

                Section("Gratitude") {
                    HStack {
                        TextField("I'm grateful for...", text: $gratitudeInput)
                        Button("Add") {
                            if !gratitudeInput.isEmpty {
                                gratitude.append(gratitudeInput)
                                gratitudeInput = ""
                            }
                        }
                        .disabled(gratitudeInput.isEmpty)
                    }

                    if !gratitude.isEmpty {
                        ForEach(gratitude.indices, id: \.self) { index in
                            HStack {
                                Text("• \(gratitude[index])")
                                Spacer()
                                Button {
                                    gratitude.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Highlights") {
                    HStack {
                        TextField("Best part of the day...", text: $highlightInput)
                        Button("Add") {
                            if !highlightInput.isEmpty {
                                highlights.append(highlightInput)
                                highlightInput = ""
                            }
                        }
                        .disabled(highlightInput.isEmpty)
                    }

                    if !highlights.isEmpty {
                        ForEach(highlights.indices, id: \.self) { index in
                            HStack {
                                Text("⭐ \(highlights[index])")
                                Spacer()
                                Button {
                                    highlights.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section("Challenges") {
                    HStack {
                        TextField("Something difficult...", text: $challengeInput)
                        Button("Add") {
                            if !challengeInput.isEmpty {
                                challenges.append(challengeInput)
                                challengeInput = ""
                            }
                        }
                        .disabled(challengeInput.isEmpty)
                    }

                    if !challenges.isEmpty {
                        ForEach(challenges.indices, id: \.self) { index in
                            HStack {
                                Text("💪 \(challenges[index])")
                                Spacer()
                                Button {
                                    challenges.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Section {
                    Toggle("Share with partner", isOn: $isShared)
                }
            }
            .navigationTitle("New Journal Entry")
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
                            let success = await viewModel.createJournalEntry(
                                date: date,
                                mood: selectedMood,
                                title: title.isEmpty ? nil : title,
                                content: content,
                                gratitude: gratitude.isEmpty ? nil : gratitude,
                                highlights: highlights.isEmpty ? nil : highlights,
                                challenges: challenges.isEmpty ? nil : challenges,
                                isShared: isShared
                            )
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Journal Entry Detail View
struct JournalEntryDetailView: View {
    let entry: JournalEntry
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            if let mood = entry.mood {
                                Text(mood.emoji)
                                    .font(.system(size: 48))
                            }
                            Spacer()
                            if entry.isShared {
                                Label("Shared", systemImage: "person.2.fill")
                                    .font(.caption)
                                    .foregroundStyle(.blue)
                            }
                        }

                        Text(entry.displayTitle)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Divider()

                    // Content
                    Text(entry.content)
                        .font(.body)

                    // Gratitude
                    if let gratitude = entry.gratitude, !gratitude.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Gratitude", systemImage: "heart.fill")
                                .font(.headline)
                                .foregroundStyle(.pink)

                            ForEach(gratitude, id: \.self) { item in
                                Text("• \(item)")
                                    .font(.body)
                            }
                        }
                    }

                    // Highlights
                    if let highlights = entry.highlights, !highlights.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Highlights", systemImage: "star.fill")
                                .font(.headline)
                                .foregroundStyle(.yellow)

                            ForEach(highlights, id: \.self) { item in
                                Text("⭐ \(item)")
                                    .font(.body)
                            }
                        }
                    }

                    // Challenges
                    if let challenges = entry.challenges, !challenges.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 12) {
                            Label("Challenges", systemImage: "exclamationmark.triangle.fill")
                                .font(.headline)
                                .foregroundStyle(.orange)

                            ForEach(challenges, id: \.self) { item in
                                Text("💪 \(item)")
                                    .font(.body)
                            }
                        }
                    }

                    // Timestamps
                    Divider()

                    Text("Created \(entry.createdAt, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
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
            .alert("Delete Journal Entry", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteJournalEntry(entryId: entry.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this journal entry? This action cannot be undone.")
            }
        }
    }
}

// MARK: - Mood Button
struct MoodButton: View {
    let mood: Mood
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 40))

                Text(mood.displayName)
                    .font(.caption)
                    .foregroundStyle(.primary)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Empty State
struct EmptyJournalView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No journal entries yet")
                .font(.title3)
                .fontWeight(.semibold)

            Text("Start journaling to track your thoughts and feelings")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    JournalView()
}
