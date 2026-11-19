import SwiftUI
import SwiftData

struct AddUnitsView: View {
    @Bindable var sticker: Sticker
    @Environment(\.dismiss) private var dismiss

    @State private var quantityText = ""

    private var quantity: Int? { Int(quantityText) }
    private var isValid: Bool { (quantity ?? 0) >= 1 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quantity to Add") {
                    TextField("e.g. 10", text: $quantityText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Add Units")
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
        }
    }

    private func save() {
        guard let quantity, quantity >= 1 else { return }

        sticker.record(quantity, type: .added)
        dismiss()
    }
}
