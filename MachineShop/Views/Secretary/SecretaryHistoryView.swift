//
//  SecretaryHistoryView.swift
//  MachineShop
//
//  SCREEN: finished job orders, newest first. Tap one to see its details.
//

import SwiftUI

struct SecretaryHistoryView: View {
    @ObservedObject var controller: SecretaryJobsController

    var body: some View {
        NavigationStack {
            List {
                if !controller.doneJobs.isEmpty {
                    Text(controller.doneJobs.count == 1
                         ? "1 completed job"
                         : "\(controller.doneJobs.count) completed jobs")
                        .font(.subheadline)
                        .foregroundStyle(Theme.mutedInk)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 8, leading: 20, bottom: 2, trailing: 16))
                }

                ForEach(controller.filteredHistory) { job in
                    NavigationLink {
                        JobDetailView(job: job)
                    } label: {
                        JobRowView(job: job)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .searchable(text: $controller.historySearchText, prompt: "Search name or phone")
            .refreshable { await controller.load() }
            .safeAreaInset(edge: .top) {
                if controller.isOffline { OfflineBanner(lastUpdated: controller.lastUpdated) }
            }
            .overlay {
                if controller.filteredHistory.isEmpty {
                    if controller.historySearchText.isEmpty {
                        EmptyStateView(icon: "clock.arrow.circlepath",
                                       title: "No finished jobs yet",
                                       message: "Completed job orders will show up here.")
                    } else {
                        EmptyStateView(icon: "magnifyingglass",
                                       title: "No matches",
                                       message: "Try a different name or phone number.")
                    }
                }
            }
            .navigationTitle("History")
        }
    }
}
