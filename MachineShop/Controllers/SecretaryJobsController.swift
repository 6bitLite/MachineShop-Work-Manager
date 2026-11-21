//
//  SecretaryJobsController.swift
//  MachineShop
//

import SwiftUI
import Combine
import Supabase

@MainActor
class SecretaryJobsController: ObservableObject {
    @Published var jobs: [JobOrder] = []
    @Published var finishedJobName: String?
    @Published var isOffline = false
    @Published var lastUpdated: Date?
    @Published var searchText = ""
    @Published var historySearchText = ""

    private func matches(_ job: JobOrder, _ text: String) -> Bool {
        let query = text.trimmingCharacters(in: .whitespaces)
        guard !query.isEmpty else { return true }
        return job.customerName.localizedCaseInsensitiveContains(query)
            || (job.customerPhone ?? "").contains(query)
    }

    /// Jobs still being worked on, filtered by the Jobs search box.
    var filteredJobs: [JobOrder] {
        jobs.filter { $0.status != "done" && matches($0, searchText) }
    }

    /// Finished jobs, newest first, filtered by the History search box.
    var doneJobs: [JobOrder] {
        jobs.filter { $0.status == "done" }
            .sorted { ($0.completedAt ?? "") > ($1.completedAt ?? "") }
    }

    var filteredHistory: [JobOrder] {
        doneJobs.filter { matches($0, historySearchText) }
    }

    func count(status: String) -> Int {
        jobs.filter { $0.status == status }.count
    }

    private let cacheKey = "secretary-jobs"

    init() {
        if let cached = CacheStore.shared.load([JobOrder].self, key: cacheKey) {
            jobs = cached.value
            lastUpdated = cached.updatedAt
        }
    }

    func load() async {
        do {
            let newJobs: [JobOrder] = try await supabase.from("job_orders")
                .select("*, job_tasks(id, status)")
                .order("created_at", ascending: false)
                .execute().value

            // Detect jobs that just flipped to done
            let previous = Dictionary(uniqueKeysWithValues: jobs.map { ($0.id, $0.status) })
            if let justDone = newJobs.first(where: {
                $0.status == "done" && previous[$0.id] != nil && previous[$0.id] != "done"
            }) {
                finishedJobName = justDone.customerName
            }

            jobs = newJobs
            lastUpdated = Date()
            isOffline = false
            CacheStore.shared.save(newJobs, key: cacheKey)
        } catch {
            if Task.isCancelled { return }
            isOffline = true   // keep showing what we already have
        }
    }

    func listen() async {
        let channel = supabase.channel("secretary-jobs")
        let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "job_orders")
        await channel.subscribe()
        for await _ in changes { await load() }
        // The screen went away (for example the user switched tabs): close the channel,
        // otherwise coming back would try to reuse a channel that is already joined.
        await supabase.removeChannel(channel)
    }
}
