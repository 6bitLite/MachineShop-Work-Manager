//
//  LoginView.swift
//  MachineShop
//
//  SCREEN: sign in. Accounts are created by the admin, so there is no sign-up.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var auth: AuthController
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var showForgotAlert = false
    @FocusState private var focused: Field?

    private enum Field { case email, password }

    private var canSubmit: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && !password.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                hero
                formCard
                    .padding(.horizontal, 20)
                    .padding(.top, -28)
                Spacer(minLength: 24)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Theme.background.ignoresSafeArea())
        .alert("Forgot your password?", isPresented: $showForgotAlert) {
            Button("OK") {}
        } message: {
            Text("Please contact the office and ask the admin to change your password.")
        }
    }

    private var hero: some View {
        VStack(spacing: 14) {
            Image(systemName: "gearshape.2.fill")
                .font(.system(size: 40))
                .foregroundStyle(.white)
                .frame(width: 84, height: 84)
                .background(.white.opacity(0.15), in: Circle())
            Text(Theme.appName)
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
            Text("Machine shop job tracking")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 64)
        .padding(.bottom, 64)
        .background {
            UnevenRoundedRectangle(bottomLeadingRadius: 36, bottomTrailingRadius: 36)
                .fill(Theme.heroGradient)
                .ignoresSafeArea(edges: .top)
        }
    }

    private var formCard: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Sign in")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.ink)
                Text("Use the account your admin gave you.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.mutedInk)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            IconField(icon: "envelope.fill") {
                TextField("Email", text: $email)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
                    .textContentType(.username)
                    .submitLabel(.next)
                    .focused($focused, equals: .email)
                    .onSubmit { focused = .password }
            }

            IconField(icon: "lock.fill") {
                Group {
                    if showPassword {
                        TextField("Password", text: $password)
                    } else {
                        SecureField("Password", text: $password)
                    }
                }
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.password)
                .submitLabel(.go)
                .focused($focused, equals: .password)
                .onSubmit { signIn() }

                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(Theme.mutedInk)
                }
            }

            if let err = auth.errorMessage {
                Label(err, systemImage: "exclamationmark.triangle.fill")
                    .font(.subheadline)
                    .foregroundStyle(Theme.danger)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            Button {
                signIn()
            } label: {
                if auth.isSigningIn {
                    ProgressView().tint(.white)
                } else {
                    Text("Sign in")
                }
            }
            .buttonStyle(BigButtonStyle())
            .disabled(!canSubmit || auth.isSigningIn)
            .opacity(canSubmit ? 1 : 0.5)

            Button("Forgot password?") { showForgotAlert = true }
                .font(.subheadline.weight(.semibold))
                .padding(.top, 2)
        }
        .padding(20)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: Theme.cardShadow, radius: 12, y: 5)
    }

    private func signIn() {
        focused = nil
        Task {
            await auth.signIn(email: email.trimmingCharacters(in: .whitespaces),
                              password: password)
        }
    }
}
