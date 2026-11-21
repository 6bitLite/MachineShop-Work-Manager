//
//  BigButtonStyle.swift
//  MachineShop
//
//  Large tap target, easy to hit with dirty or gloved hands.
//

import SwiftUI

struct BigButtonStyle: ButtonStyle {
    var color: Color = Theme.accent

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 54)
            .foregroundStyle(.white)
            .background(color, in: RoundedRectangle(cornerRadius: 14))
            .shadow(color: color.opacity(0.3), radius: 8, y: 4)
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}
