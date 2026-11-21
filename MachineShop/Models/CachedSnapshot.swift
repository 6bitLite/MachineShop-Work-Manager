//
//  CachedSnapshot.swift
//  MachineShop
//

import Foundation
import SwiftData

/// One saved copy of a list (jobs, tasks, profile) so the app can show
/// the last-loaded data when there is no connection.
@Model
final class CachedSnapshot {
    @Attribute(.unique) var key: String
    var data: Data
    var updatedAt: Date

    init(key: String, data: Data, updatedAt: Date = Date()) {
        self.key = key
        self.data = data
        self.updatedAt = updatedAt
    }
}
