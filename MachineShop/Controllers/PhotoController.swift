//
//  PhotoController.swift
//  MachineShop
//
//  CONTROLLER: turns a stored photo path into a temporary viewable link.
//

import SwiftUI
import Combine
import Supabase

@MainActor
class PhotoController: ObservableObject {
    @Published var url: URL?
    @Published var failed = false

    func load(path: String) async {
        do {
            url = try await supabase.storage
                .from("job-photos")
                .createSignedURL(path: path, expiresIn: 3600)
            failed = false
        } catch {
            if Task.isCancelled { return }
            failed = true
        }
    }
}
