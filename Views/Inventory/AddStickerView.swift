import SwiftUI
import SwiftData
import PhotosUI

struct AddStickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var name = ""
    @State private var unitPriceText = ""
    @State private var initialQuantityText = "0"

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && Decimal(userInput: unitPriceText) != nil
            && Int(initialQuantityText).map { $0 >= 0 } ?? false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    photoPicker
                }

                Section("Details") {
                    TextField("Name", text: $name)

                    HStack {
                        Text("€")
                            .foregroundStyle(.secondary)
                        TextField("Unit Price", text: $unitPriceText)
                            .keyboardType(.decimalPad)
                    }

                    HStack {
                        Text("Initial Quantity")
                        Spacer()
                        TextField("0", text: $initialQuantityText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("New Sticker")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: save)
                        .disabled(!isValid)
                }
            }
            .onChange(of: selectedPhoto) { _, newItem in
                Task {
                    photoData = try? await newItem?.loadTransferable(type: Data.self)
                }
            }
        }
    }

    @ViewBuilder
    private var photoPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if let data = photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipped()
                    .contentShape(Rectangle())
            } else {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.largeTitle)
                        Text("Select Photo")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 40)
                    Spacer()
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func save() {
        guard let price = Decimal(userInput: unitPriceText),
              let quantity = Int(initialQuantityText),
              quantity >= 0
        else { return }

        let sticker = Sticker(
            name: name.trimmingCharacters(in: .whitespaces),
            photoData: photoData,
            unitPrice: price
        )
        modelContext.insert(sticker)
        sticker.record(quantity, type: .added)

        dismiss()
    }
}
