//
//  TaskDraft.swift
//  MachineShop
//
//  MODEL layer: one unsaved task row in the "New Job Order" form.
//

import Foundation

struct TaskDraft: Identifiable {
    let id = UUID()
    var specialty: Specialty?
    var workerId: UUID?
    var notes = ""
    /// When true, workers outside this specialty can be picked too.
    var allowOtherWorkers = false
}
