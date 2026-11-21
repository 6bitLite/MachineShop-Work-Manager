//
//  TaskCardView.swift
//  MachineShop
//
//  One task in the worker's list.
//

import SwiftUI
import Foundation

struct TaskCardView: View {
    let task: JobTask

    var body: some View {
        StatusCard(status: task.status) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(task.jobOrder?.customerName ?? "")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Theme.ink)
                    Spacer()
                    SpecialtyTag(name: task.specialty?.name ?? "")
                }

                if let desc = task.jobOrder?.description, !desc.isEmpty {
                    Text(desc)
                        .font(.body)
                        .foregroundStyle(Theme.ink)
                        .lineLimit(2)
                }

                if let notes = task.notes, !notes.isEmpty {
                    Label(notes, systemImage: "note.text")
                        .font(.subheadline)
                        .foregroundStyle(Theme.mutedInk)
                        .lineLimit(2)
                }

                if task.status == "done", let date = task.completedDate {
                    Label(SupabaseDate.completedLabel(date), systemImage: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(Theme.green)
                }
            }
        }
    }
}
