import SwiftUI
import UserNotifications

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: NotificationViewModel
    @Environment(\.dismiss) var dismiss

    @State private var pushNotificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            Form {
                // Push Notifications Section
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Push Notifications")
                                .font(.body)

                            Text(pushNotificationStatusText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if pushNotificationStatus == .notDetermined {
                            Button("Enable") {
                                Task {
                                    await requestPushPermission()
                                }
                            }
                            .buttonStyle(.bordered)
                        } else if pushNotificationStatus == .denied {
                            Button("Settings") {
                                openSettings()
                            }
                            .buttonStyle(.bordered)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                } footer: {
                    Text("Enable push notifications to receive real-time updates about tasks, routines, and events.")
                }

                // Notification Preferences
                if let preferences = viewModel.preferences {
                    Section("Preferences") {
                        Toggle("Email Notifications", isOn: Binding(
                            get: { preferences.emailNotifications },
                            set: { newValue in
                                Task {
                                    await viewModel.updatePreferences(emailNotifications: newValue)
                                }
                            }
                        ))

                        Toggle("Push Notifications", isOn: Binding(
                            get: { preferences.pushNotifications },
                            set: { newValue in
                                Task {
                                    await viewModel.updatePreferences(pushNotifications: newValue)
                                }
                            }
                        ))
                        .disabled(pushNotificationStatus != .authorized)
                    }

                    Section("Notification Types") {
                        Toggle("Task Reminders", isOn: Binding(
                            get: { preferences.taskReminders },
                            set: { newValue in
                                Task {
                                    await viewModel.updatePreferences(taskReminders: newValue)
                                }
                            }
                        ))

                        Toggle("Routine Reminders", isOn: Binding(
                            get: { preferences.routineReminders },
                            set: { newValue in
                                Task {
                                    await viewModel.updatePreferences(routineReminders: newValue)
                                }
                            }
                        ))

                        Toggle("Event Reminders", isOn: Binding(
                            get: { preferences.eventReminders },
                            set: { newValue in
                                Task {
                                    await viewModel.updatePreferences(eventReminders: newValue)
                                }
                            }
                        ))

                        Toggle("Partner Activity", isOn: Binding(
                            get: { preferences.partnerActivity },
                            set: { newValue in
                                Task {
                                    await viewModel.updatePreferences(partnerActivity: newValue)
                                }
                            }
                        ))
                    } footer: {
                        Text("Choose which types of notifications you want to receive.")
                    }
                }

                // Info Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            icon: "checkmark.circle.fill",
                            iconColor: .green,
                            title: "Task Reminders",
                            description: "Get notified about assigned tasks and upcoming due dates"
                        )

                        Divider()

                        InfoRow(
                            icon: "repeat.circle.fill",
                            iconColor: .blue,
                            title: "Routine Reminders",
                            description: "Stay on track with your daily routines and habits"
                        )

                        Divider()

                        InfoRow(
                            icon: "calendar.circle.fill",
                            iconColor: .purple,
                            title: "Event Reminders",
                            description: "Never miss important events and appointments"
                        )

                        Divider()

                        InfoRow(
                            icon: "person.circle.fill",
                            iconColor: .pink,
                            title: "Partner Activity",
                            description: "See when your partner completes tasks or adds events"
                        )
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("About Notifications")
                }
            }
            .navigationTitle("Notification Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                await viewModel.fetchPreferences()
                pushNotificationStatus = await viewModel.checkPushNotificationPermission()
            }
            .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    openSettings()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("To enable push notifications, please go to Settings and allow notifications for TwoDo.")
            }
        }
    }

    private var pushNotificationStatusText: String {
        switch pushNotificationStatus {
        case .authorized:
            return "Enabled"
        case .denied:
            return "Disabled in Settings"
        case .notDetermined:
            return "Not configured"
        case .provisional:
            return "Provisional"
        case .ephemeral:
            return "Ephemeral"
        @unknown default:
            return "Unknown"
        }
    }

    private func requestPushPermission() async {
        let granted = await viewModel.requestPushNotificationPermission()
        pushNotificationStatus = await viewModel.checkPushNotificationPermission()

        if !granted {
            showPermissionAlert = true
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NotificationSettingsView(viewModel: NotificationViewModel())
}
