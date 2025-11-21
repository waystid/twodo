import Foundation
import SwiftUI

@MainActor
class CoupleViewModel: ObservableObject {
    @Published var couple: Couple?
    @Published var members: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient = APIClient.shared

    // MARK: - Fetch Couple
    func fetchCouple() async {
        isLoading = true
        errorMessage = nil

        do {
            let response: GetCoupleResponse = try await apiClient.request(.getCouple)
            couple = response.couple
            members = response.members
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Couple
    func createCouple(name: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = CreateCoupleRequest(name: name)
            let response: CreateCoupleResponse = try await apiClient.request(.createCouple, body: request)
            couple = response.couple
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Join Couple
    func joinCouple(inviteCode: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let request = JoinCoupleRequest(inviteCode: inviteCode)
            let response: JoinCoupleResponse = try await apiClient.request(.joinCouple, body: request)
            couple = response.couple
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Generate Invite Code
    func generateInviteCode() async -> String? {
        isLoading = true
        errorMessage = nil

        do {
            let response: GenerateInviteResponse = try await apiClient.request(.generateInvite)
            isLoading = false
            return response.inviteCode
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Update Couple
    func updateCouple(name: String) async {
        guard let coupleId = couple?.id else { return }

        isLoading = true
        errorMessage = nil

        do {
            let request = UpdateCoupleRequest(name: name)
            let response: UpdateCoupleResponse = try await apiClient.request(
                .updateCouple(coupleId),
                body: request
            )
            couple = response.couple
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Leave Couple
    func leaveCouple() async -> Bool {
        guard let coupleId = couple?.id else { return false }

        isLoading = true
        errorMessage = nil

        do {
            let _: EmptyResponse = try await apiClient.request(.leaveCouple(coupleId))
            couple = nil
            members = []
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
