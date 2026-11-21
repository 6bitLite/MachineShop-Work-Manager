//
//  Models.swift
//  MachineShop
//
//  MODEL layer: plain data types that mirror the Supabase tables.
//

import Foundation

struct Profile: Codable, Identifiable {
    let id: UUID
    let fullName: String
    let role: String

    enum CodingKeys: String, CodingKey {
        case id, role
        case fullName = "full_name"
    }
}

/// Used when a query only returns someone's name (for example the worker on a task).
struct PersonName: Codable {
    let fullName: String

    enum CodingKeys: String, CodingKey { case fullName = "full_name" }
}

struct Specialty: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
}

struct WorkerSpecialtyLink: Codable {
    let specialtyId: Int

    enum CodingKeys: String, CodingKey { case specialtyId = "specialty_id" }
}

struct WorkerWithSpecialties: Codable, Identifiable {
    let id: UUID
    let fullName: String
    let workerSpecialties: [WorkerSpecialtyLink]

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case workerSpecialties = "worker_specialties"
    }
}

struct TaskStub: Codable {
    let id: UUID
    let status: String
}

struct JobOrder: Codable, Identifiable {
    let id: UUID
    var customerName: String
    var customerPhone: String?
    var description: String?
    var price: Double?
    var photoPath: String?
    var status: String
    var createdAt: String?
    var completedAt: String?
    var jobTasks: [TaskStub]?

    enum CodingKeys: String, CodingKey {
        case id, description, price, status
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case photoPath = "photo_path"
        case createdAt = "created_at"
        case completedAt = "completed_at"
        case jobTasks = "job_tasks"
    }

    var completedDate: Date? { SupabaseDate.parse(completedAt) }

    var taskCount: Int { jobTasks?.count ?? 0 }
    var completedTaskCount: Int { jobTasks?.filter { $0.status == "done" }.count ?? 0 }
}

struct JobTask: Codable, Identifiable {
    let id: UUID
    let jobOrderId: UUID
    let specialtyId: Int
    let assignedTo: UUID
    var notes: String?
    var status: String
    var completedAt: String?
    var jobOrder: JobOrder?
    var specialty: Specialty?
    var worker: PersonName?

    enum CodingKeys: String, CodingKey {
        case id, notes, status, specialty, worker
        case jobOrderId = "job_order_id"
        case specialtyId = "specialty_id"
        case assignedTo = "assigned_to"
        case completedAt = "completed_at"
        case jobOrder = "job_orders"
    }

    var completedDate: Date? { SupabaseDate.parse(completedAt) }
}

struct NewJobOrder: Encodable {
    let customerName: String
    let customerPhone: String
    let description: String
    let price: Double?
    let photoPath: String?
    let createdBy: UUID

    enum CodingKeys: String, CodingKey {
        case description, price
        case customerName = "customer_name"
        case customerPhone = "customer_phone"
        case photoPath = "photo_path"
        case createdBy = "created_by"
    }
}

struct NewJobTask: Encodable {
    let jobOrderId: UUID
    let specialtyId: Int
    let assignedTo: UUID
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case notes
        case jobOrderId = "job_order_id"
        case specialtyId = "specialty_id"
        case assignedTo = "assigned_to"
    }
}
