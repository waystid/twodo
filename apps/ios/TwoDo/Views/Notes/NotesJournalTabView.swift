import SwiftUI

struct NotesJournalTabView: View {
    @State private var selectedSection = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("Section", selection: $selectedSection) {
                    Text("Notes").tag(0)
                    Text("Journal").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                TabView(selection: $selectedSection) {
                    NotesView()
                        .tag(0)

                    JournalView()
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
}

#Preview {
    NotesJournalTabView()
}
