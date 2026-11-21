//
//  DetailRow.swift
//  MachineShop
//
//  One "icon  label ........ value" line, used on the Profile screen.
//

import SwiftUI

struct DetailRow: View {
    var icon: String? = nil
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            if let icon {
                Image(systemName: icon)
                    .foregroundStyle(Theme.accent)
                    .frame(width: 22)
            }
            Text(label)
                .foregroundStyle(Theme.mutedInk)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(Theme.ink)
                .multilineTextAlignment(.trailing)
        }
    }
}
