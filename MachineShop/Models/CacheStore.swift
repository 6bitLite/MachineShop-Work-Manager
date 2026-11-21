//
//  CacheStore.swift
//  MachineShop
//

import Foundation
import SwiftData

@MainActor
final class CacheStore {
    static let shared = CacheStore()

    private let container: ModelContainer
    private var context: ModelContext { container.mainContext }

    private init() {
        do {
            container = try ModelContainer(for: CachedSnapshot.self)
        } catch {
            // If the on-disk store fails, fall back to memory so the app still runs
            container = try! ModelContainer(
                for: CachedSnapshot.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        }
    }

    func save<T: Encodable>(_ value: T, key: String) {
        guard let data = try? JSONEncoder().encode(value) else { return }
        if let existing = fetch(key: key) {
            existing.data = data
            existing.updatedAt = Date()
        } else {
            context.insert(CachedSnapshot(key: key, data: data))
        }
        try? context.save()
    }

    func load<T: Decodable>(_ type: T.Type, key: String) -> (value: T, updatedAt: Date)? {
        guard let snapshot = fetch(key: key),
              let value = try? JSONDecoder().decode(T.self, from: snapshot.data)
        else { return nil }
        return (value, snapshot.updatedAt)
    }

    /// Called on logout so the next person never sees the previous user's data.
    func clearAll() {
        try? context.delete(model: CachedSnapshot.self)
        try? context.save()
    }

    private func fetch(key: String) -> CachedSnapshot? {
        let descriptor = FetchDescriptor<CachedSnapshot>(
            predicate: #Predicate { $0.key == key })
        return try? context.fetch(descriptor).first
    }
}
