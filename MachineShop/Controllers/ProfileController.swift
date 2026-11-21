//
//  ProfileController.swift
//  MachineShop
//

import SwiftUI
import Combine
import Supabase

private struct SpecialtyRow: Codable {
    let specialties: Specialty?
}

@MainActor
class ProfileController: ObservableObject {
    @Published var specialties: [String] = []

    func load(workerId: UUID) async {
        let rows: [SpecialtyRow] = (try? await supabase.from("worker_specialties")
            .select("specialties(id, name)")
            .eq("worker_id", value: workerId)
            .execute().value) ?? []
        specialties = rows.compactMap { $0.specialties?.name }.sorted()
    }
}
