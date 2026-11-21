//
//  WorkerTasksController.swift
//  MachineShop
//

import SwiftUI
import Combine
import Supabase

@MainActor
class WorkerTasksController: ObservableObject {
    @Published var tasks: [JobTask] = []
    @Published var history: [JobTask] = []
    @Published var newTaskAlert = false
    @Published var isOffline = false
    @Published var lastUpdated: Date?
    @Published var actionError: String?

    let workerId: UUID
    private var cacheKey: String { "worker-tasks-\(workerId.uuidString)" }
    private var historyCacheKey: String { "worker-history-\(workerId.uuidString)" }

    init(workerId: UUID) {
        self.workerId = workerId
        if let cached = CacheStore.shared.load([JobTask].self, key: cacheKey) {
            tasks = cached.value
            lastUpdated = cached.updatedAt
        }
        if let cachedHistory = CacheStore.shared.load([JobTask].self, key: historyCacheKey) {
            history = cachedHistory.value
        }
    }

    /// Refreshes both the active tasks and the finished ones.
    func refresh() async {
        await load()
        await loadHistory()
    }

    func loadHistory() async {
        do {
            let done: [JobTask] = try await supabase.from("job_tasks")
                .select("*, job_orders(*), specialty:specialties(*)")
                .eq("assigned_to", value: workerId)
                .eq("status", value: "done")
                .order("completed_at", ascending: false)
                .limit(100)
                .execute().value
            history = done
            CacheStore.shared.save(done, key: historyCacheKey)
        } catch {
            // Offline: keep the saved copy. load() already shows the offline banner.
        }
    }

    func load() async {
        do {
            let newTasks: [JobTask] = try await supabase.from("job_tasks")
                .select("*, job_orders(*), specialty:specialties(*)")
                .eq("assigned_to", value: workerId)
                .neq("status", value: "done")
                .order("created_at", ascending: false)
                .execute().value

            // Alert when a brand new task shows up
            let oldIds = Set(tasks.map { $0.id })
            if !tasks.isEmpty, newTasks.contains(where: { !oldIds.contains($0.id) }) {
                newTaskAlert = true
            }

            tasks = newTasks
            lastUpdated = Date()
            isOffline = false
            CacheStore.shared.save(newTasks, key: cacheKey)
        } catch {
            if Task.isCancelled { return }
            isOffline = true
        }
    }

    func listen() async {
        let channel = supabase.channel("worker-tasks")
        let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "job_tasks")
        await channel.subscribe()
        for await _ in changes { await refresh() }
        await supabase.removeChannel(channel)
    }

    @discardableResult
    func markDone(_ task: JobTask) async -> Bool {
        do {
            try await supabase.from("job_tasks")
                .update(["status": "done",
                         "completed_at": ISO8601DateFormatter().string(from: Date())])
                .eq("id", value: task.id)
                .execute()
            await refresh()
            return true
        } catch {
            actionError = "No connection, so this task was not marked done. Try again when you're online."
            return false
        }
    }
}
