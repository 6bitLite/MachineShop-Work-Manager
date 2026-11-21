//
//  WorkerHistoryView.swift
//  MachineShop
//
//  SCREEN: tasks this worker has already finished, newest first.
//

import SwiftUI

struct WorkerHistoryView: View {
    @ObservedObject var controller: WorkerTasksController

    var body: some View {
        NavigationStack {
            List {
                if !controller.history.isEmpty {
                    Text(controller.history.count == 1
                         ? "1 completed task"
                         : "\(controller.history.count) completed tasks")
                        .font(.subheadline)
                        .foregroundStyle(Theme.mutedInk)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 2, trailing: 16))
                }

                ForEach(controller.history) { task in
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
            .refreshable { await controller.refresh() }
            .safeAreaInset(edge: .top) {
                if controller.isOffline { OfflineBanner(lastUpdated: controller.lastUpdated) }
            }
            .overlay {
                if controller.history.isEmpty {
                    EmptyStateView(icon: "clock.arrow.circlepath",
                                   title: "No finished tasks yet",
                                   message: "Tasks you mark as done will show up here.")
                }
            }
            .navigationTitle("History")
        }
    }
}
