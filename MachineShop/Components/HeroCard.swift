//
//  HeroCard.swift
//  MachineShop
//
//  A dark steel banner for greetings and the profile header.
//

import SwiftUI

struct HeroCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.heroGradient, in: RoundedRectangle(cornerRadius: 22))
            .shadow(color: Theme.cardShadow, radius: 10, y: 4)
    }
}
