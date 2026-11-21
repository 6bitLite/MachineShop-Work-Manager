//
//  StatusCard.swift
//  MachineShop
//
//  A white card with a colored stripe on the left showing status.
//

import SwiftUI

struct StatusCard<Content: View>: View {
    let status: String
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(.leading, 22)
            .padding([.trailing, .vertical], 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.card)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(Theme.statusColor(status))
                    .frame(width: 6)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Theme.cardShadow, radius: 8, y: 3)
    }
}
