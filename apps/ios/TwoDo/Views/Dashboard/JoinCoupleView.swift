import SwiftUI

struct JoinCoupleView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var coupleViewModel = CoupleViewModel()

    @State private var inviteCode = ""
    @State private var showSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green.gradient)

                    Text("Join Your Partner")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Enter the invite code from your partner")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)

                // Form
                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: "Invite Code",
                        text: $inviteCode,
                        icon: "key"
                    )
                    .textInputAutocapitalization(.characters)

                    if let errorMessage = coupleViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    CustomButton(
                        title: "Join Couple",
                        isLoading: coupleViewModel.isLoading,
                        backgroundColor: .green
                    ) {
                        Task {
                            let success = await coupleViewModel.joinCouple(inviteCode: inviteCode)
                            if success {
                                showSuccess = true
                            }
                        }
                    }
                    .disabled(inviteCode.isEmpty)
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
            .alert("Welcome!", isPresented: $showSuccess) {
                Button("OK") {
                    authViewModel.checkAuthStatus()
                    dismiss()
                }
            } message: {
                Text("You've successfully joined your couple! Let's organize life together.")
            }
        }
    }
}

#Preview {
    JoinCoupleView()
        .environmentObject(AuthViewModel())
}
