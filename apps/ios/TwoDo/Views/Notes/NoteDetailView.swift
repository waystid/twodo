import SwiftUI

struct NoteDetailView: View {
    let note: Note
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss

    @State private var showEditSheet = false
    @State private var showDeleteAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Title
                    Text(note.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Metadata
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Image(systemName: note.noteType.icon)
                            Text(note.noteType.displayName)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        if note.isPrivate {
                            HStack(spacing: 6) {
                                Image(systemName: "lock.fill")
                                Text("Private")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                        }

                        if note.sharedWithPartner {
                            HStack(spacing: 6) {
                                Image(systemName: "person.2.fill")
                                Text("Shared")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.blue)
                        }
                    }

                    Divider()

                    // Content
                    Text(note.content)
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    // Tags
                    if let tags = note.tags, !tags.isEmpty {
                        Divider()

                        VStack(alignment: .leading, spacing: 8) {
                            Text("Tags")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            FlowLayout(spacing: 8) {
                                ForEach(tags, id: \.self) { tag in
                                    Text("#\(tag)")
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.blue.opacity(0.1))
                                        .foregroundStyle(.blue)
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }

                    // Timestamps
                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Created \(note.createdAt, style: .relative) ago")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if note.updatedAt != note.createdAt {
                            Text("Updated \(note.updatedAt, style: .relative) ago")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
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
            .sheet(isPresented: $showEditSheet) {
                EditNoteSheet(note: note, viewModel: viewModel)
            }
            .alert("Delete Note", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await viewModel.deleteNote(noteId: note.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this note? This action cannot be undone.")
            }
        }
    }
}

// MARK: - New Note Sheet
struct NewNoteSheet: View {
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss

    @State private var noteType: NoteType = .general
    @State private var title = ""
    @State private var content = ""
    @State private var tags: [String] = []
    @State private var tagInput = ""
    @State private var isPrivate = false
    @State private var sharedWithPartner = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Type") {
                    Picker("Note Type", selection: $noteType) {
                        ForEach(NoteType.allCases.filter { $0 != .journal }, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                }

                Section("Details") {
                    TextField("Title", text: $title)
                        .font(.headline)

                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...15)
                }

                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button("Add") {
                            if !tagInput.isEmpty {
                                tags.append(tagInput)
                                tagInput = ""
                            }
                        }
                        .disabled(tagInput.isEmpty)
                    }

                    if !tags.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagChip(tag: tag, onDelete: {
                                    tags.removeAll { $0 == tag }
                                })
                            }
                        }
                    }
                }

                Section("Privacy") {
                    Toggle("Private (only you can see)", isOn: $isPrivate)

                    if !isPrivate {
                        Toggle("Share with partner", isOn: $sharedWithPartner)
                    }
                }
            }
            .navigationTitle("New Note")
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
                            let success = await viewModel.createNote(
                                noteType: noteType,
                                title: title,
                                content: content,
                                tags: tags.isEmpty ? nil : tags,
                                isPrivate: isPrivate,
                                sharedWithPartner: sharedWithPartner
                            )
                            if success {
                                dismiss()
                            }
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Edit Note Sheet
struct EditNoteSheet: View {
    let note: Note
    @ObservedObject var viewModel: NoteViewModel
    @Environment(\.dismiss) var dismiss

    @State private var title: String
    @State private var content: String
    @State private var tags: [String]
    @State private var tagInput = ""
    @State private var isPrivate: Bool
    @State private var sharedWithPartner: Bool

    init(note: Note, viewModel: NoteViewModel) {
        self.note = note
        self.viewModel = viewModel
        _title = State(initialValue: note.title)
        _content = State(initialValue: note.content)
        _tags = State(initialValue: note.tags ?? [])
        _isPrivate = State(initialValue: note.isPrivate)
        _sharedWithPartner = State(initialValue: note.sharedWithPartner)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                        .font(.headline)

                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...15)
                }

                Section("Tags") {
                    HStack {
                        TextField("Add tag", text: $tagInput)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                        Button("Add") {
                            if !tagInput.isEmpty {
                                tags.append(tagInput)
                                tagInput = ""
                            }
                        }
                        .disabled(tagInput.isEmpty)
                    }

                    if !tags.isEmpty {
                        FlowLayout(spacing: 8) {
                            ForEach(tags, id: \.self) { tag in
                                TagChip(tag: tag, onDelete: {
                                    tags.removeAll { $0 == tag }
                                })
                            }
                        }
                    }
                }

                Section("Privacy") {
                    Toggle("Private (only you can see)", isOn: $isPrivate)

                    if !isPrivate {
                        Toggle("Share with partner", isOn: $sharedWithPartner)
                    }
                }
            }
            .navigationTitle("Edit Note")
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
                            await viewModel.updateNote(
                                noteId: note.id,
                                title: title,
                                content: content,
                                tags: tags.isEmpty ? nil : tags,
                                isPrivate: isPrivate,
                                sharedWithPartner: sharedWithPartner
                            )
                            dismiss()
                        }
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
}

// MARK: - Tag Chip
struct TagChip: View {
    let tag: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.subheadline)

            Button {
                onDelete()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.1))
        .foregroundStyle(.blue)
        .cornerRadius(16)
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.offsets[index].x, y: bounds.minY + result.offsets[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var offsets: [CGPoint]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var size = CGSize.zero
            var offsets: [CGPoint] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)

                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                offsets.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, subviewSize.height)
                currentX += subviewSize.width + spacing
                size.width = max(size.width, currentX - spacing)
            }

            size.height = currentY + lineHeight
            self.size = size
            self.offsets = offsets
        }
    }
}

#Preview {
    NoteDetailView(
        note: Note(
            id: "1",
            coupleId: "1",
            noteType: .general,
            entityType: nil,
            entityId: nil,
            title: "Sample Note",
            content: "This is a sample note with some content.",
            tags: ["important", "personal"],
            isPrivate: false,
            sharedWithPartner: true,
            createdById: "1",
            createdAt: Date(),
            updatedAt: Date()
        ),
        viewModel: NoteViewModel()
    )
}
