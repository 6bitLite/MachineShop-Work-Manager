//
//  StatusBadge.swift
//  MachineShop
//
//  Small colored label showing Waiting / In progress / Done.
//

import SwiftUI

struct StatusBadge: View {
    let status: String

    var body: some View {
        Text(Theme.statusLabel(status))
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.statusColor(status))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.statusColor(status).opacity(0.14), in: Capsule())
    }
}
