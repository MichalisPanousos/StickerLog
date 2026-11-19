import SwiftUI
import SwiftData
import PhotosUI

struct AddStickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var isLoadingPhoto = false
    @State private var name = ""
    @State private var unitPriceText = ""
    @State private var initialQuantityText = "0"

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
            && Decimal(userInput: unitPriceText) != nil
            && Int(quantityInput: initialQuantityText) != nil
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
                    if !initialQuantityText.isEmpty && Int(quantityInput: initialQuantityText) == nil {
                        Text(invalidQuantityMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
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
                        .disabled(!isValid || isLoadingPhoto)
                }
            }
            // .task(id:) cancels the previous load when a new photo is picked,
            // so a slow earlier load can't overwrite a newer selection.
            .task(id: selectedPhoto) {
                guard let item = selectedPhoto else { return }
                isLoadingPhoto = true
                let original = try? await item.loadTransferable(type: Data.self)
                guard !Task.isCancelled else { return }
                photoData = original.flatMap(Self.downscaledJPEG)
                isLoadingPhoto = false
            }
        }
    }

    @ViewBuilder
    private var photoPicker: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            if isLoadingPhoto {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            } else if photoData != nil {
                StickerPhotoView(data: photoData)
                    .frame(height: 200)
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

    /// Shrinks a picked photo so its longest side is at most `maxDimension` px and re-encodes it as JPEG.
    /// Transparent areas become white, since JPEG has no alpha.
    private static func downscaledJPEG(_ data: Data) -> Data? {
        let maxDimension: CGFloat = 1024
        guard let image = UIImage(data: data) else { return nil }
        let scale = min(1, maxDimension / max(image.size.width, image.size.height))
        let size = CGSize(width: image.size.width * scale, height: image.size.height * scale)

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let resized = UIGraphicsImageRenderer(size: size, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            image.draw(in: CGRect(origin: .zero, size: size))
        }
        return resized.jpegData(compressionQuality: 0.8)
    }

    private func save() {
        guard let price = Decimal(userInput: unitPriceText),
              let quantity = Int(quantityInput: initialQuantityText)
        else { return }

        let sticker = Sticker(
            name: name.trimmingCharacters(in: .whitespaces),
            photoData: photoData,
            unitPrice: price
        )
        modelContext.insert(sticker)
        // A sticker created with 0 units gets no "+0" history entry.
        if quantity > 0 {
            sticker.record(quantity, type: .added)
        } else {
            try? modelContext.save()
        }

        dismiss()
    }
}
