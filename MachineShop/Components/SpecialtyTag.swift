//
//  SpecialtyTag.swift
//  MachineShop
//
//  Blue label for a work type such as Reboring or Welding.
//

import SwiftUI

struct SpecialtyTag: View {
    let name: String

    var body: some View {
        Label(name, systemImage: Theme.specialtyIcon(name))
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Theme.accent)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(Theme.accent.opacity(0.14), in: Capsule())
    }
}
