//
//  InfoBlock.swift
//  MachineShop
//
//  A small heading with a paragraph under it, inside a card.
//

import SwiftUI

struct InfoBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Theme.mutedInk)
            Text(text)
                .font(.body)
                .foregroundStyle(Theme.ink)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.cardShadow, radius: 8, y: 3)
    }
}
