import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var coupleViewModel = CoupleViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()

    @State private var showEditProfileSheet = false
    @State private var showChangePasswordSheet = false
    @State private var showLogoutAlert = false
    @State private var showLeaveAlert = false

    var body: some View {
        NavigationStack {
            List {
                // Profile Section
                Section {
                    if let user = authViewModel.currentUser {
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color.blue.gradient)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Text(user.name.prefix(1).uppercased())
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.white)
                                )

                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.name)
                                    .font(.headline)
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                showEditProfileSheet = true
                            } label: {
                                Image(systemName: "pencil.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(.blue)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }

                // Couple Section
                Section("Couple") {
                    if let couple = coupleViewModel.couple {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "heart.fill")
                                    .foregroundStyle(.red)
                                Text(couple.name)
                                    .font(.headline)
                            }

                            if let inviteCode = couple.inviteCode,
                               let expiresAt = couple.inviteCodeExpiresAt,
                               expiresAt > Date() {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Invite Code")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(inviteCode)
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.semibold)
                                }
                            }
                        }
                        .padding(.vertical, 4)

                        Button {
                            Task {
                                await coupleViewModel.generateInviteCode()
                            }
                        } label: {
                            Label("Generate Invite Code", systemImage: "link")
                        }

                        Button(role: .destructive) {
                            showLeaveAlert = true
                        } label: {
                            Label("Leave Couple", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    }
                }

                // Notification Settings
                Section("Notifications") {
                    NavigationLink {
                        NotificationSettingsView(viewModel: notificationViewModel)
                    } label: {
                        Label("Notification Preferences", systemImage: "bell")
                    }
                }

                // Security
                Section("Security") {
                    Button {
                        showChangePasswordSheet = true
                    } label: {
                        Label("Change Password", systemImage: "key")
                    }
                }

                // About
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    Link(destination: URL(string: "https://twodo.app/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://twodo.app/terms")!) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }

                // Account
                Section {
                    Button(role: .destructive) {
                        showLogoutAlert = true
                    } label: {
                        Label("Log Out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showEditProfileSheet) {
                EditProfileSheet(authViewModel: authViewModel)
            }
            .sheet(isPresented: $showChangePasswordSheet) {
                ChangePasswordSheet(authViewModel: authViewModel)
            }
            .alert("Log Out", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    authViewModel.logout()
                }
            } message: {
                Text("Are you sure you want to log out?")
            }
            .alert("Leave Couple", isPresented: $showLeaveAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Leave", role: .destructive) {
                    Task {
                        if let coupleId = coupleViewModel.couple?.id {
                            await coupleViewModel.leaveCouple(coupleId: coupleId)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to leave this couple? You will lose access to all shared data.")
            }
            .task {
                await coupleViewModel.fetchCouple()
                await notificationViewModel.fetchPreferences()
            }
        }
    }
}

// MARK: - Edit Profile Sheet
struct EditProfileSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var name: String
    @State private var email: String

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        _name = State(initialValue: authViewModel.currentUser?.name ?? "")
        _email = State(initialValue: authViewModel.currentUser?.email ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Profile Information") {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .autocorrectionDisabled()
                }

                Section {
                    Text("Changes to your profile will be visible to your partner.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // TODO: Implement profile update API call
                        dismiss()
                    }
                    .disabled(name.isEmpty || email.isEmpty)
                }
            }
        }
    }
}

// MARK: - Change Password Sheet
struct ChangePasswordSheet: View {
    @ObservedObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("Current Password", text: $currentPassword)
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmPassword)
                }

                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section {
                    Text("Your password must be at least 8 characters long.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if newPassword != confirmPassword {
                            errorMessage = "New passwords don't match"
                        } else if newPassword.count < 8 {
                            errorMessage = "Password must be at least 8 characters"
                        } else {
                            // TODO: Implement password change API call
                            dismiss()
                        }
                    }
                    .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
}
