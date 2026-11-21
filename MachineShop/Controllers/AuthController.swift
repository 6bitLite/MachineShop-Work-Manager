//
//  AuthController.swift
//  MachineShop
//

import SwiftUI
import Combine
import Supabase

@MainActor
class AuthController: ObservableObject {
    @Published var profile: Profile?
    @Published var email: String?
    @Published var isLoading = true
    @Published var isSigningIn = false
    @Published var errorMessage: String?

    func checkSession() async {
        defer { isLoading = false }
        do {
            let session = try await supabase.auth.session
            email = session.user.email
            try await loadProfile(userId: session.user.id)
        } catch {
            // Offline fallback: reuse the saved profile if this phone was signed in before
            if let user = supabase.auth.currentSession?.user,
               let cached = CacheStore.shared.load(
                    Profile.self, key: "profile-\(user.id.uuidString)"),
               cached.value.id == user.id {
                email = user.email
                profile = cached.value
            } else {
                profile = nil
            }
        }
    }

    func signIn(email: String, password: String) async {
        isSigningIn = true
        defer { isSigningIn = false }
        do {
            let session = try await supabase.auth.signIn(email: email, password: password)
            self.email = session.user.email
            try await loadProfile(userId: session.user.id)
            errorMessage = nil
        } catch {
            errorMessage = "Invalid email or password"
        }
    }

    func signOut() async {
        try? await supabase.auth.signOut()
        CacheStore.shared.clearAll()
        email = nil
        profile = nil
    }

    private func loadProfile(userId: UUID) async throws {
        let loaded: Profile = try await supabase
            .from("profiles")
            .select()
            .eq("id", value: userId)
            .single()
            .execute()
            .value
        profile = loaded
        CacheStore.shared.save(loaded, key: "profile-\(userId.uuidString)")
    }
}
