//
//  OutlineButtonStyle.swift
//  MachineShop
//
//  A softer button for actions like Log out.
//

import SwiftUI

struct OutlineButtonStyle: ButtonStyle {
    var color: Color = Theme.danger

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(color)
            .background(color.opacity(configuration.isPressed ? 0.16 : 0.08),
                        in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14)
                .stroke(color.opacity(0.5), lineWidth: 1))
    }
}
