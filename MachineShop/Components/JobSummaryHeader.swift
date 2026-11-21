//
//  JobSummaryHeader.swift
//  MachineShop
//
//  Three tiles at the top of the secretary's list: waiting, in progress, done.
//

import SwiftUI

struct JobSummaryHeader: View {
    let waiting: Int
    let inProgress: Int
    let done: Int

    var body: some View {
        HStack(spacing: 12) {
            StatTile(value: waiting, label: "Waiting", status: "pending")
            StatTile(value: inProgress, label: "In progress", status: "in_progress")
            StatTile(value: done, label: "Done", status: "done")
        }
    }
}
