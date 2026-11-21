//
//  SectionLabel.swift
//  MachineShop
//
//  A small icon + title used above a group of content.
//

import SwiftUI

struct SectionLabel: View {
    let icon: String
    let title: String

    var body: some View {
        Label {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.ink)
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
        }
    }
}
