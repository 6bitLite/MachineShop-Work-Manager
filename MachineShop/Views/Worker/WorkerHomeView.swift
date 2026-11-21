//
//  WorkerHomeView.swift
//  MachineShop
//
//  SCREEN: the worker's list of assigned tasks. Tap a task to open it.
//

import SwiftUI

struct WorkerHomeView: View {
    @EnvironmentObject var auth: AuthController
    @ObservedObject var controller: WorkerTasksController

    private var greeting: String {
        if let first = auth.profile?.fullName.split(separator: " ").first {
            return "Hello, \(first)"
        }
        return "Hello"
    }

    private var summary: String {
        switch controller.tasks.count {
        case 0: return "You're all caught up."
        case 1: return "1 task waiting for you"
        default: return "\(controller.tasks.count) tasks waiting for you"
        }
    }

    var body: some View {
        NavigationStack {
            List {
                HeroCard {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(greeting)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.white)
                        Text(summary)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))

                ForEach(controller.tasks) { task in
                    NavigationLink {
                        TaskDetailView(task: task, controller: controller)
                    } label: {
                        TaskCardView(task: task)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .safeAreaInset(edge: .top) {
                if controller.isOffline { OfflineBanner(lastUpdated: controller.lastUpdated) }
            }
            .overlay {
                if controller.tasks.isEmpty {
                    EmptyStateView(icon: "checkmark.seal.fill",
                                   title: "No tasks right now",
                                   message: "New ones will show up here.")
                }
            }
            .navigationTitle("My Tasks")
            .alert("New task assigned", isPresented: $controller.newTaskAlert) {
                Button("OK") {}
            }
            .refreshable { await controller.refresh() }
        }
    }
}
