//
//  MainTabs.swift
//  MachineShop
//
//  The bottom tab bars. Each one creates its controller once and shares it
//  between its tabs, so there is only one live connection per role.
//

import SwiftUI

struct SecretaryTabs: View {
    let userId: UUID
    @StateObject private var controller = SecretaryJobsController()

    var body: some View {
        TabView {
            SecretaryHomeView(userId: userId, controller: controller)
                .tabItem { Label("Jobs", systemImage: "list.clipboard") }
            SecretaryHistoryView(controller: controller)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .task { await controller.load() }
        .task { await controller.listen() }
    }
}

struct WorkerTabs: View {
    @StateObject private var controller: WorkerTasksController

    init(workerId: UUID) {
        _controller = StateObject(wrappedValue: WorkerTasksController(workerId: workerId))
    }

    var body: some View {
        TabView {
            WorkerHomeView(controller: controller)
                .tabItem { Label("Tasks", systemImage: "wrench.and.screwdriver") }
            WorkerHistoryView(controller: controller)
                .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .task { await controller.refresh() }
        .task { await controller.listen() }
    }
}
