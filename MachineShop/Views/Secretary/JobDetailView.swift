//
//  JobDetailView.swift
//  MachineShop
//
//  SCREEN: everything about one job order, including each task's progress.
//

import SwiftUI
import Foundation

struct JobDetailView: View {
    let job: JobOrder
    @StateObject private var controller = JobDetailController()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                StatusCard(status: job.status) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(job.customerName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(Theme.ink)
                            Spacer()
                            StatusBadge(status: job.status)
                        }
                        if let phone = job.customerPhone, !phone.isEmpty {
                            Label(phone, systemImage: "phone.fill")
                                .font(.subheadline)
                                .foregroundStyle(Theme.mutedInk)
                                .textSelection(.enabled)
                        }
                        if job.status == "done", let date = job.completedDate {
                            Label(SupabaseDate.completedLabel(date), systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .foregroundStyle(Theme.green)
                        }
                        if let price = job.price {
                            Text("₱\(price, specifier: "%.2f")")
                                .font(.system(.title3, design: .monospaced).weight(.semibold))
                                .foregroundStyle(Theme.accent)
                        }
                    }
                }

                if let desc = job.description, !desc.isEmpty {
                    InfoBlock(title: "Work needed", text: desc)
                }

                if let path = job.photoPath {
                    JobPhotoView(path: path)
                        .frame(maxHeight: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: Theme.cardShadow, radius: 8, y: 3)
                }

                SectionLabel(icon: "wrench.and.screwdriver.fill",
                             title: "Tasks (\(job.completedTaskCount) of \(job.taskCount) done)")
                    .padding(.top, 4)

                if let error = controller.errorMessage {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(.red)
                }

                ForEach(controller.tasks) { task in
                    TaskStatusRow(task: task)
                }
            }
            .padding(16)
        }
        .background(Theme.background)
        .navigationTitle("Job details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await controller.load(jobId: job.id) }
    }
}
