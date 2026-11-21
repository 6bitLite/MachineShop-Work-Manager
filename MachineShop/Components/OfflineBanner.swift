//
//  OfflineBanner.swift
//  MachineShop
//

import SwiftUI
import Foundation

struct OfflineBanner: View {
    let lastUpdated: Date?

    private var message: String {
        guard let lastUpdated else { return "Offline" }
        return "Offline. Showing data from " +
            lastUpdated.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text(message).font(.footnote.weight(.semibold))
            Spacer()
        }
        .foregroundStyle(Theme.ink)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Theme.amber.opacity(0.25))
    }
}
