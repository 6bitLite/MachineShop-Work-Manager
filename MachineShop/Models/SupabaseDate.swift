//
//  SupabaseDate.swift
//  MachineShop
//
//  MODEL layer: turns the timestamps Supabase sends (text) into real dates.
//

import Foundation

enum SupabaseDate {
    private static let withFraction: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let plain = ISO8601DateFormatter()

    static func parse(_ text: String?) -> Date? {
        guard let text else { return nil }
        return withFraction.date(from: text) ?? plain.date(from: text)
    }

    /// For example "Completed Nov 17, 2026 at 4:32 PM"
    static func completedLabel(_ date: Date) -> String {
        "Completed " + date.formatted(date: .abbreviated, time: .shortened)
    }
}
