//
//  JobDetailController.swift
//  MachineShop
//
//  CONTROLLER: loads the tasks (and assigned workers) for one job order.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class JobDetailController: ObservableObject {
    @Published var tasks: [JobTask] = []
    @Published var errorMessage: String?

    func load(jobId: UUID) async {
        do {
            tasks = try await supabase.from("job_tasks")
                .select("*, specialty:specialties(*), worker:profiles(full_name)")
                .eq("job_order_id", value: jobId)
                .order("created_at", ascending: true)
                .execute().value
            errorMessage = nil
        } catch {
            if Task.isCancelled { return }
            errorMessage = "Couldn't load the tasks. Check your connection."
        }
    }
}
