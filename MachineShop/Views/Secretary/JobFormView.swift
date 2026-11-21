//
//  JobFormView.swift
//  MachineShop
//
//  SCREEN: create a job order (customer, item, photo, price) and assign its tasks.
//

import SwiftUI
import PhotosUI

struct JobFormView: View {
    let userId: UUID
    @Environment(\.dismiss) var dismiss
    @StateObject private var controller = JobFormController()
    @State private var showCamera = false
    @State private var pickerItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $controller.customerName)
                    TextField("Phone number", text: $controller.customerPhone)
                        .keyboardType(.phonePad)
                } header: {
                    Label("Customer", systemImage: "person.fill")
                }

                Section {
                    TextField("Description of work needed",
                              text: $controller.description,
                              axis: .vertical)
                        .lineLimit(3...6)
                    TextField("Price (₱)", text: $controller.price)
                        .keyboardType(.decimalPad)
                } header: {
                    Label("Job", systemImage: "doc.text.fill")
                }

                Section {
                    photoPreview
                    HStack(spacing: 10) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            Button {
                                showCamera = true
                            } label: {
                                Label("Take photo", systemImage: "camera.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        PhotosPicker(selection: $pickerItem, matching: .images) {
                            Label("Choose photo", systemImage: "photo.on.rectangle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                } header: {
                    Label("Photo of the item", systemImage: "camera.viewfinder")
                }

                Section {
                    ForEach($controller.tasks) { $task in
                        VStack(alignment: .leading, spacing: 8) {
                            Picker("Work type", selection: $task.specialty) {
                                Text("Select...").tag(Specialty?.none)
                                ForEach(controller.specialties) {
                                    Text($0.name).tag(Specialty?.some($0))
                                }
                            }
                            .onChange(of: task.specialty) { _, _ in
                                task.workerId = nil
                                task.allowOtherWorkers = false
                            }

                            if task.specialty != nil {
                                let specialists = controller.workers(for: task.specialty)
                                let others = controller.otherWorkers(for: task.specialty)
                                let showOthers = task.allowOtherWorkers || specialists.isEmpty

                                if specialists.isEmpty {
                                    Label("No specialist for this yet, so every worker is listed.",
                                          systemImage: "person.crop.circle.badge.exclamationmark")
                                        .font(.subheadline)
                                        .foregroundStyle(Theme.amber)
                                }

                                Picker("Worker", selection: $task.workerId) {
                                    Text("Select...").tag(UUID?.none)
                                    ForEach(specialists) {
                                        Text($0.fullName).tag(UUID?.some($0.id))
                                    }
                                    if showOthers {
                                        ForEach(others) {
                                            Text("\($0.fullName) (other)").tag(UUID?.some($0.id))
                                        }
                                    }
                                }

                                if !specialists.isEmpty && !others.isEmpty {
                                    Toggle("Choose someone else", isOn: $task.allowOtherWorkers)
                                        .onChange(of: task.allowOtherWorkers) { _, allowed in
                                            // Turning it off while a non-specialist is picked clears the choice
                                            if !allowed, let id = task.workerId,
                                               !specialists.contains(where: { $0.id == id }) {
                                                task.workerId = nil
                                            }
                                        }
                                }
                            }
                            TextField("Notes for this task", text: $task.notes)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete(perform: controller.removeTask)

                    Button {
                        controller.addTask()
                    } label: {
                        Label("Add another task", systemImage: "plus.circle.fill")
                    }
                } header: {
                    Label("Tasks", systemImage: "wrench.and.screwdriver.fill")
                } footer: {
                    Text("Swipe a task to the left to remove it. Each worker is notified of their own task.")
                }

                if let err = controller.errorMessage {
                    Label(err, systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(Theme.danger)
                }
            }
            .navigationTitle("New Job Order")
            .navigationBarTitleDisplayMode(.inline)
            .scrollContentBackground(.hidden)
            .background(Theme.background)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task { if await controller.save(createdBy: userId) { dismiss() } }
                    }
                    .disabled(!controller.canSave || controller.isSaving)
                }
            }
            .overlay {
                if controller.isSaving {
                    ProgressView("Saving...")
                        .padding(24)
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView(image: $controller.photo).ignoresSafeArea()
            }
            .onChange(of: pickerItem) { _, item in
                Task {
                    if let data = try? await item?.loadTransferable(type: Data.self) {
                        controller.photo = UIImage(data: data)
                    }
                }
            }
            .task { await controller.load() }
        }
    }

    @ViewBuilder
    private var photoPreview: some View {
        if let photo = controller.photo {
            Image(uiImage: photo)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 220)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 6) {
                Image(systemName: "camera.viewfinder")
                    .font(.system(size: 34))
                    .foregroundStyle(Theme.accent)
                Text("No photo yet")
                    .font(.subheadline)
                    .foregroundStyle(Theme.mutedInk)
            }
            .frame(maxWidth: .infinity, minHeight: 110)
            .background(Theme.accent.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        }
    }
}
