//
//  JobFormController.swift
//  MachineShop
//
//  CONTROLLER: logic behind the "New Job Order" screen.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class JobFormController: ObservableObject {
    @Published var customerName = ""
    @Published var customerPhone = ""
    @Published var description = ""
    @Published var price = ""
    @Published var photo: UIImage?
    @Published var tasks: [TaskDraft] = [TaskDraft()]
    @Published var isSaving = false
    @Published var errorMessage: String?

    @Published var specialties: [Specialty] = []
    @Published var allWorkers: [WorkerWithSpecialties] = []

    func load() async {
        do {
            specialties = try await supabase.from("specialties")
                .select().order("name").execute().value

            allWorkers = try await supabase.from("profiles")
                .select("id, full_name, worker_specialties(specialty_id)")
                .eq("role", value: "worker")
                .execute().value
            errorMessage = nil
        } catch {
            if Task.isCancelled { return }
            errorMessage = "Couldn't load workers and work types. Check your connection."
        }
    }

    /// Workers who have this specialty (the recommended choices).
    func workers(for specialty: Specialty?) -> [WorkerWithSpecialties] {
        guard let spec = specialty else { return [] }
        return allWorkers.filter { w in
            w.workerSpecialties.contains { $0.specialtyId == spec.id }
        }
    }

    /// Every other worker, for when the secretary wants someone outside the specialty.
    func otherWorkers(for specialty: Specialty?) -> [WorkerWithSpecialties] {
        let specialistIds = Set(workers(for: specialty).map { $0.id })
        return allWorkers.filter { !specialistIds.contains($0.id) }
    }

    func addTask() { tasks.append(TaskDraft()) }
    func removeTask(at offsets: IndexSet) { tasks.remove(atOffsets: offsets) }

    var canSave: Bool {
        !customerName.isEmpty && !tasks.isEmpty &&
        tasks.allSatisfy { $0.specialty != nil && $0.workerId != nil }
    }

    private func uploadPhoto() async throws -> String? {
        guard let photo, let data = photo.jpegData(compressionQuality: 0.7) else { return nil }
        let path = "\(UUID().uuidString).jpg"
        try await supabase.storage.from("job-photos").upload(
            path, data: data, options: FileOptions(contentType: "image/jpeg"))
        return path
    }

    func save(createdBy: UUID) async -> Bool {
        isSaving = true
        defer { isSaving = false }
        do {
            let photoPath = try await uploadPhoto()

            let job: JobOrder = try await supabase.from("job_orders")
                .insert(NewJobOrder(
                    customerName: customerName,
                    customerPhone: customerPhone,
                    description: description,
                    price: Double(price),
                    photoPath: photoPath,
                    createdBy: createdBy))
                .select().single().execute().value

            let newTasks = tasks.map {
                NewJobTask(jobOrderId: job.id,
                           specialtyId: $0.specialty!.id,
                           assignedTo: $0.workerId!,
                           notes: $0.notes.isEmpty ? nil : $0.notes)
            }
            try await supabase.from("job_tasks").insert(newTasks).execute()
            return true
        } catch {
            errorMessage = "Could not save job: \(error.localizedDescription)"
            return false
        }
    }
}
