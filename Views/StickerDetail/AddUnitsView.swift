import SwiftUI
import SwiftData

struct AddUnitsView: View {
    let sticker: Sticker
    @Environment(\.dismiss) private var dismiss

    @State private var quantityText = ""
    @FocusState private var quantityFocused: Bool

    private var quantity: Int? { Int(quantityInput: quantityText) }
    private var isValid: Bool { (quantity ?? 0) >= 1 }

    var body: some View {
        NavigationStack {
            Form {
                Section("Quantity to Add") {
                    TextField("e.g. 10", text: $quantityText)
                        .keyboardType(.numberPad)
                        .focused($quantityFocused)
                    if !quantityText.isEmpty && quantity == nil {
                        Text(invalidQuantityMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
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
            .onAppear { quantityFocused = true }
        }
    }

    private func save() {
        guard let quantity, quantity >= 1 else { return }

        sticker.record(quantity, type: .added)
        dismiss()
    }
}
