import SwiftUI

struct CreateCoupleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var coupleViewModel = CoupleViewModel()

    @State private var coupleName = ""
    @State private var showInviteCode = false
    @State private var inviteCode: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.pink.gradient)

                    Text("Create Your Couple")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Choose a name for your couple")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                // Form
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Couple Name",
                        text: $coupleName,
                        icon: "heart"
                    )

                    if let errorMessage = coupleViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CustomButton(
                        title: "Create Couple",
                        isLoading: coupleViewModel.isLoading
                    ) {
                        Task {
                            let success = await coupleViewModel.createCouple(name: coupleName)
                            if success {
                                // Generate invite code
                                inviteCode = await coupleViewModel.generateInviteCode()
                                showInviteCode = true
                            }
                        }
                    }
                    .disabled(coupleName.isEmpty)
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showInviteCode) {
                InviteCodeSheet(inviteCode: inviteCode ?? "") {
                    // Refresh auth to update couple status
                    authViewModel.checkAuthStatus()
                    dismiss()
                }
            }
        }
    }
}

struct InviteCodeSheet: View {
    let inviteCode: String
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Success icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)

                VStack(spacing: 8) {
                    Text("Couple Created!")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Share this code with your partner to join")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                // Invite code display
                VStack(spacing: 12) {
                    Text("Invite Code")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(inviteCode)
                        .font(.system(.title, design: .monospaced))
                        .fontWeight(.bold)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .onTapGesture {
                            UIPasteboard.general.string = inviteCode
                        }

                    Text("Tap to copy • Expires in 48 hours")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        shareInviteCode(inviteCode)
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share Code")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(10)
                    }

                    Button("Done") {
                        onDone()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundStyle(.primary)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func shareInviteCode(_ code: String) {
        let activityVC = UIActivityViewController(
            activityItems: ["Join me on TwoDo! Use invite code: \(code)"],
            applicationActivities: nil
        )

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

#Preview {
    CreateCoupleView()
        .environmentObject(AuthViewModel())
}
