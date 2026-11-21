//
//  TaskDetailView.swift
//  MachineShop
//
//  SCREEN: one task in full, with the photo and the "Mark as done" button.
//

import SwiftUI
import Foundation

struct TaskDetailView: View {
    let task: JobTask
    @ObservedObject var controller: WorkerTasksController
    @Environment(\.dismiss) private var dismiss
    @State private var confirmDone = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StatusCard(status: task.status) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(task.jobOrder?.customerName ?? "")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Theme.ink)
                        HStack {
                            SpecialtyTag(name: task.specialty?.name ?? "")
                            StatusBadge(status: task.status)
                        }
                    }
                }

                if let desc = task.jobOrder?.description, !desc.isEmpty {
                    InfoBlock(title: "Work needed", text: desc)
                }

                if let notes = task.notes, !notes.isEmpty {
                    InfoBlock(title: "Notes for this task", text: notes)
                }

                if let path = task.jobOrder?.photoPath {
                    JobPhotoView(path: path)
                        .frame(maxHeight: 360)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.cardShadow, radius: 8, y: 3)
                }

                if task.status == "done" {
                    // Read-only when opened from History
                    if let date = task.completedDate {
                        Label(SupabaseDate.completedLabel(date), systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundStyle(Theme.green)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                } else {
                    Button {
                        confirmDone = true
                    } label: {
                        Label("Mark as done", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(BigButtonStyle(color: Theme.green))
                    .padding(.top, 8)
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("Task")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("Mark this task as done?",
                            isPresented: $confirmDone,
                            titleVisibility: .visible) {
            Button("Mark as done") {
                Task {
                    if await controller.markDone(task) {
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                }
            }
        }
        .alert("Couldn't update", isPresented: Binding(
            get: { controller.actionError != nil },
            set: { if !$0 { controller.actionError = nil } })
        ) {
            Button("OK") {}
        } message: {
            Text(controller.actionError ?? "")
        }
    }
}
