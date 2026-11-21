//
//  JobRowView.swift
//  MachineShop
//
//  One job in the secretary's list.
//

import SwiftUI
import Foundation

struct JobRowView: View {
    let job: JobOrder

    var body: some View {
        StatusCard(status: job.status) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(job.customerName)
                            .font(.headline)
                            .foregroundStyle(Theme.ink)
                        if let phone = job.customerPhone, !phone.isEmpty {
                            Label(phone, systemImage: "phone.fill")
                                .font(.subheadline)
                                .foregroundStyle(Theme.mutedInk)
                        }
                    }
                    Spacer()
                    StatusBadge(status: job.status)
                }

                if job.taskCount > 0 {
                    ProgressView(value: Double(job.completedTaskCount),
                                 total: Double(job.taskCount))
                        .tint(Theme.statusColor(job.status))
                }

                HStack {
                    if job.status == "done", let date = job.completedDate {
                        Label(SupabaseDate.completedLabel(date), systemImage: "checkmark.circle.fill")
                            .font(.footnote)
                            .foregroundStyle(Theme.green)
                    } else if job.taskCount > 0 {
                        Text("\(job.completedTaskCount) of \(job.taskCount) tasks done")
                            .font(.footnote)
                            .foregroundStyle(Theme.mutedInk)
                    }
                    Spacer()
                    if let price = job.price {
                        Text("₱\(price, specifier: "%.2f")")
                            .font(.system(.headline, design: .monospaced))
                            .foregroundStyle(Theme.accent)
                    }
                }
            }
        }
    }
}
