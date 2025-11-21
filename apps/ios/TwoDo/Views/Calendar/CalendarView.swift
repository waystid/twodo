import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showNewEventSheet = false
    @State private var showEventListSheet = false
    @State private var selectedEvent: Event?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Month Navigation
                    MonthNavigationBar(viewModel: viewModel)

                    // Calendar Grid
                    CalendarGridView(
                        viewModel: viewModel,
                        onDateTap: { date in
                            viewModel.selectedDate = date
                            showEventListSheet = true
                        }
                    )
                    .padding()

                    Divider()
                        .padding(.vertical)

                    // Selected Date Events
                    SelectedDateEventsView(
                        viewModel: viewModel,
                        onEventTap: { event in
                            selectedEvent = event
                        }
                    )
                }
            }
            .navigationTitle("Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showNewEventSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewEventSheet) {
                NewEventSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showEventListSheet) {
                EventListSheet(
                    date: viewModel.selectedDate,
                    viewModel: viewModel,
                    onEventTap: { event in
                        showEventListSheet = false
                        selectedEvent = event
                    }
                )
            }
            .sheet(item: $selectedEvent) { event in
                EventDetailView(event: event, viewModel: viewModel)
            }
            .task {
                await viewModel.fetchEventsForMonth(viewModel.currentMonth)
            }
            .onChange(of: viewModel.currentMonth) { _, newMonth in
                Task {
                    await viewModel.fetchEventsForMonth(newMonth)
                }
            }
        }
    }
}

// MARK: - Month Navigation Bar
struct MonthNavigationBar: View {
    @ObservedObject var viewModel: CalendarViewModel

    var body: some View {
        HStack {
            Button {
                viewModel.moveToPreviousMonth()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }

            Spacer()

            VStack(spacing: 2) {
                Text(viewModel.currentMonth, format: .dateTime.month(.wide))
                    .font(.title2)
                    .fontWeight(.semibold)
                Text(viewModel.currentMonth, format: .dateTime.year())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                viewModel.moveToNextMonth()
            } label: {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.blue)
            }
        }
        .padding()

        Button {
            viewModel.moveToToday()
        } label: {
            Text("Today")
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .cornerRadius(8)
        }
        .padding(.bottom, 8)
    }
}

// MARK: - Calendar Grid View
struct CalendarGridView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let onDateTap: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let weekDays = ["S", "M", "T", "W", "T", "F", "S"]

    var body: some View {
        VStack(spacing: 8) {
            // Week day headers
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Array(viewModel.daysInMonth(for: viewModel.currentMonth).enumerated()), id: \.offset) { _, date in
                    if let date = date {
                        CalendarDayCell(
                            date: date,
                            isSelected: Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate),
                            isToday: Calendar.current.isDateInToday(date),
                            hasEvents: viewModel.hasEvents(on: date),
                            onTap: {
                                onDateTap(date)
                            }
                        )
                    } else {
                        Color.clear
                            .frame(height: 44)
                    }
                }
            }
        }
    }
}

// MARK: - Calendar Day Cell
struct CalendarDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasEvents: Bool
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(spacing: 4) {
                Text(date, format: .dateTime.day())
                    .font(.body)
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? .white : (isToday ? .blue : .primary))

                if hasEvents {
                    Circle()
                        .fill(isSelected ? .white : .blue)
                        .frame(width: 4, height: 4)
                } else {
                    Spacer()
                        .frame(height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                isSelected ? Color.blue :
                isToday ? Color.blue.opacity(0.1) :
                Color.clear
            )
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Selected Date Events View
struct SelectedDateEventsView: View {
    @ObservedObject var viewModel: CalendarViewModel
    let onEventTap: (Event) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(viewModel.selectedDate, format: .dateTime.month().day().weekday(.wide))
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)

            let events = viewModel.events(for: viewModel.selectedDate)

            if events.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)

                    Text("No events")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            } else {
                VStack(spacing: 8) {
                    ForEach(events.sorted(by: { $0.startDate < $1.startDate })) { event in
                        EventRowView(event: event, onTap: {
                            onEventTap(event)
                        })
                    }
                }
                .padding(.horizontal)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Event Row View
struct EventRowView: View {
    let event: Event
    let onTap: () -> Void

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 12) {
                // Time indicator
                VStack(alignment: .leading, spacing: 2) {
                    if event.isAllDay {
                        Text("All Day")
                            .font(.caption)
                            .fontWeight(.medium)
                    } else {
                        Text(event.startDate, style: .time)
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                .frame(width: 60, alignment: .leading)

                // Color bar
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.blue)
                    .frame(width: 4)

                // Event details
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    HStack(spacing: 8) {
                        if let location = event.location, !location.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "location.fill")
                                    .font(.caption2)
                                Text(location)
                                    .font(.caption)
                            }
                            .foregroundStyle(.secondary)
                        }

                        if event.reminderMinutes != nil {
                            Image(systemName: "bell.fill")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        if event.recurrence != nil {
                            Image(systemName: "repeat")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Event List Sheet
struct EventListSheet: View {
    let date: Date
    @ObservedObject var viewModel: CalendarViewModel
    let onEventTap: (Event) -> Void
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                let events = viewModel.events(for: date).sorted(by: { $0.startDate < $1.startDate })

                if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar")
                            .font(.system(size: 48))
                            .foregroundStyle(.secondary)

                        Text("No events")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(events) { event in
                        EventRowView(event: event, onTap: {
                            onEventTap(event)
                        })
                        .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
                        .listRowBackground(Color.clear)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle(date, format: .dateTime.month().day().weekday())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CalendarView()
}
