//
//  EmptyStateView.swift
//  MachineShop
//
//  Friendly message shown when a list has nothing in it.
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(Theme.accent.opacity(0.7))
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.ink)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Theme.mutedInk)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}
