//
//  IconField.swift
//  MachineShop
//
//  A text field with an icon on the left, used on the login screen.
//

import SwiftUI

struct IconField<Content: View>: View {
    let icon: String
    @ViewBuilder var content: Content

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(Theme.mutedInk)
                .frame(width: 22)
            content
        }
        .padding(14)
        .background(Theme.background, in: RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Theme.mutedInk.opacity(0.2)))
    }
}
