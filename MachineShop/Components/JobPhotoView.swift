//
//  JobPhotoView.swift
//  MachineShop
//
//  Shows a job's photo. The link is fetched by PhotoController.
//

import SwiftUI

struct JobPhotoView: View {
    let path: String
    @StateObject private var controller = PhotoController()

    var body: some View {
        Group {
            if controller.failed {
                Label("Photo unavailable", systemImage: "photo")
                    .font(.subheadline)
                    .foregroundStyle(Theme.mutedInk)
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                AsyncImage(url: controller.url) { image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }
            }
        }
        .task { await controller.load(path: path) }
    }
}
