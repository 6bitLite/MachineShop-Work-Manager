//
//  MachineShopApp.swift
//  MachineShop
//
//  Created by Mac-LAB on 10/19/26.
//

import SwiftUI

@main
struct MachineShopApp: App {
    @StateObject private var auth = AuthController()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoading {
                    ProgressView()
                } else if let profile = auth.profile {
                    switch profile.role {
                    case "secretary", "admin":
                        SecretaryTabs(userId: profile.id)
                    case "worker":
                        WorkerTabs(workerId: profile.id)
                    default:
                        Text("Unknown role")
                    }
                } else {
                    LoginView()
                }
            }
            .environmentObject(auth)
            .tint(Theme.accent)
            .task { await auth.checkSession() }
        }
    }
}
