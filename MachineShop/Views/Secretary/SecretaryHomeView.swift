//
//  SecretaryHomeView.swift
//  MachineShop
//
//  SCREEN: the secretary's list of job orders. Tap a job for details, + to add one.
//

import SwiftUI

struct SecretaryHomeView: View {
    let userId: UUID
    @ObservedObject var controller: SecretaryJobsController
    @State private var showForm = false

    private let rowInsets = EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16)

    var body: some View {
        NavigationStack {
            List {
                JobSummaryHeader(
                    waiting: controller.count(status: "pending"),
                    inProgress: controller.count(status: "in_progress"),
                    done: controller.count(status: "done"))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 6, trailing: 16))

                ForEach(controller.filteredJobs) { job in
                    NavigationLink {
                        JobDetailView(job: job)
                    } label: {
                        JobRowView(job: job)
                    }
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .listRowInsets(rowInsets)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .searchable(text: $controller.searchText, prompt: "Search name or phone")
            .safeAreaInset(edge: .top) {
                if controller.isOffline { OfflineBanner(lastUpdated: controller.lastUpdated) }
            }
            .overlay {
                if controller.filteredJobs.isEmpty {
                    if controller.searchText.isEmpty {
                        EmptyStateView(icon: "list.clipboard",
                                       title: "No active jobs",
                                       message: "Tap + to create a job order. Finished jobs are in History.")
                    } else {
                        EmptyStateView(icon: "magnifyingglass",
                                       title: "No matches",
                                       message: "Try a different name or phone number.")
                    }
                }
            }
            .navigationTitle("Job Orders")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { showForm = true } label: { Image(systemName: "plus") }
                }
            }
            .sheet(isPresented: $showForm) { JobFormView(userId: userId) }
            .alert("Job finished", isPresented: Binding(
                get: { controller.finishedJobName != nil },
                set: { if !$0 { controller.finishedJobName = nil } })
            ) {
                Button("OK") {}
            } message: {
                Text("\(controller.finishedJobName ?? "") is done and ready for pickup.")
            }
            .refreshable { await controller.load() }
        }
    }
}
