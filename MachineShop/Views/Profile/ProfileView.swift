//
//  ProfileView.swift
//  MachineShop
//
//  SCREEN: who is signed in (name, role, email) and the Log out button.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthController
    @StateObject private var controller = ProfileController()
    @State private var confirmLogout = false

    private var name: String { auth.profile?.fullName ?? "" }

    private var roleLabel: String {
        switch auth.profile?.role {
        case "secretary": return "Secretary"
        case "worker": return "Worker"
        case "admin": return "Admin"
        default: return "Unknown"
        }
    }

    private var initials: String {
        name.split(separator: " ").prefix(2)
            .compactMap { $0.first }.map(String.init).joined().uppercased()
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeroCard {
                        VStack(spacing: 12) {
                            Text(initials)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 96, height: 96)
                                .background(.white.opacity(0.18), in: Circle())
                                .overlay(Circle().stroke(.white.opacity(0.6), lineWidth: 2))

                            Text(name)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)

                            Text(roleLabel)
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.18), in: Capsule())
                        }
                        .frame(maxWidth: .infinity)
                    }

                    VStack(spacing: 14) {
                        DetailRow(icon: "person.fill", label: "Name", value: name)
                        Divider()
                        DetailRow(icon: "briefcase.fill", label: "Role", value: roleLabel)
                        if let email = auth.email {
                            Divider()
                            DetailRow(icon: "envelope.fill", label: "Email", value: email)
                        }
                        if auth.profile?.role == "worker" {
                            Divider()
                            DetailRow(
                                icon: "wrench.and.screwdriver.fill",
                                label: "Specialties",
                                value: controller.specialties.isEmpty
                                    ? "None assigned"
                                    : controller.specialties.joined(separator: ", "))
                        }
                    }
                    .padding(16)
                    .background(Theme.card, in: RoundedRectangle(cornerRadius: 18))
                    .shadow(color: Theme.cardShadow, radius: 8, y: 3)

                    Button {
                        confirmLogout = true
                    } label: {
                        Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    .buttonStyle(OutlineButtonStyle())
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .background(Theme.background)
            .navigationTitle("Profile")
            .confirmationDialog("Log out of your account?",
                                isPresented: $confirmLogout,
                                titleVisibility: .visible) {
                Button("Log out", role: .destructive) {
                    Task { await auth.signOut() }
                }
            }
            .task {
                if auth.profile?.role == "worker", let id = auth.profile?.id {
                    await controller.load(workerId: id)
                }
            }
        }
    }
}
