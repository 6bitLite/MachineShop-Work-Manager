//
//  StatTile.swift
//  MachineShop
//
//  A big number with a label, such as "3 Waiting".
//

import SwiftUI

struct StatTile: View {
    let value: Int
    let label: String
    let status: String

    var body: some View {
        VStack(spacing: 4) {
            Text("\(value)")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.statusColor(status))
            Text(label)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Theme.mutedInk)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.cardShadow, radius: 8, y: 3)
    }
}
