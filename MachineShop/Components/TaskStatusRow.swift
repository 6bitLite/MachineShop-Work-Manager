//
//  TaskStatusRow.swift
//  MachineShop
//
//  One task on the job details screen: work type, worker and status.
//

import SwiftUI

struct TaskStatusRow: View {
    let task: JobTask

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: Theme.specialtyIcon(task.specialty?.name ?? ""))
                .font(.title3)
                .foregroundStyle(Theme.accent)
                .frame(width: 42, height: 42)
                .background(Theme.accent.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(task.specialty?.name ?? "Task")
                    .font(.headline)
                    .foregroundStyle(Theme.ink)
                if let worker = task.worker?.fullName {
                    Text("Assigned to \(worker)")
                        .font(.subheadline)
                        .foregroundStyle(Theme.mutedInk)
                }
                if let notes = task.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.subheadline)
                        .foregroundStyle(Theme.mutedInk)
                }
            }
            Spacer()
            StatusBadge(status: task.status)
        }
        .padding(14)
        .background(Theme.card, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: Theme.cardShadow, radius: 8, y: 3)
    }
}
