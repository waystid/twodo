import SwiftUI

struct CoupleSetupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showCreateCouple = false
    @State private var showJoinCouple = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.pink.gradient)

                    Text("Set Up Your Couple")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Create a couple to start organizing life together")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 60)

                // Options
                VStack(spacing: 16) {
                    Button {
                        showCreateCouple = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.blue)

                            VStack(spacing: 4) {
                                Text("Create a Couple")
                                    .font(.headline)
                                Text("Start fresh and invite your partner")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showJoinCouple = true
                    } label: {
                        VStack(spacing: 12) {
                            Image(systemName: "person.2.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.green)

                            VStack(spacing: 4) {
                                Text("Join a Couple")
                                    .font(.headline)
                                Text("Use an invite code from your partner")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    .foregroundStyle(.primary)
                }
                .padding(.horizontal)

                Spacer()

                // Logout
                Button("Logout") {
                    authViewModel.logout()
                }
                .foregroundStyle(.red)
                .padding(.bottom, 40)
            }
            .sheet(isPresented: $showCreateCouple) {
                CreateCoupleView()
            }
            .sheet(isPresented: $showJoinCouple) {
                JoinCoupleView()
            }
        }
    }
}

#Preview {
    CoupleSetupView()
        .environmentObject(AuthViewModel())
}
