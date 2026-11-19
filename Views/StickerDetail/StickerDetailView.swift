import SwiftUI
import SwiftData

struct StickerDetailView: View {
    let sticker: Sticker
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var unitPriceText = ""
    @State private var showingDeleteConfirm = false
    @State private var showingAddUnits = false
    @State private var showingRemoveUnits = false
    @State private var pendingDelete = false
    @FocusState private var priceFocused: Bool

    private var totalValue: Decimal {
        Decimal(sticker.currentUnits) * sticker.unitPrice
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                StickerPhotoView(data: sticker.photoData, cornerRadius: 14, placeholderFont: .system(size: 48))
                    .frame(height: 280)

                VStack(alignment: .leading, spacing: 16) {
                    Text(sticker.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    unitPriceRow

                    statsRow

                    actionButtons

                    historySection
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
        }
        .navigationTitle(sticker.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { priceFocused = false }
            }
        }
        .onAppear {
            unitPriceText = sticker.unitPrice.inputString
        }
        .onDisappear {
            // Delete only after the view has left the screen, so nothing renders a deleted model.
            if pendingDelete {
                modelContext.delete(sticker)
                try? modelContext.save()
            } else {
                commitPrice()
            }
        }
        .confirmationDialog(
            "Delete this sticker? This removes it and its history permanently.",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Sticker", role: .destructive) {
                pendingDelete = true
                dismiss()
            }
        } message: {
            Text("Its sales will also be removed from events.")
        }
        .sheet(isPresented: $showingAddUnits) {
            AddUnitsView(sticker: sticker)
        }
        .sheet(isPresented: $showingRemoveUnits) {
            RemoveUnitsView(sticker: sticker)
        }
    }

    private var unitPriceRow: some View {
        HStack {
            Text("Unit Price")
                .foregroundStyle(.secondary)
            Spacer()
            HStack(spacing: 2) {
                Text("€")
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $unitPriceText)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 90)
                    .focused($priceFocused)
                    .onChange(of: priceFocused) { _, focused in
                        if !focused { commitPrice() }
                    }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    /// Saves the typed price if it was edited and is valid; otherwise restores the current price.
    private func commitPrice() {
        if unitPriceText != sticker.unitPrice.inputString,
           let price = Decimal(userInput: unitPriceText) {
            sticker.unitPrice = price
            try? modelContext.save()
        }
        unitPriceText = sticker.unitPrice.inputString
    }

    private var statsRow: some View {
        StatsHeader(
            leading: ("Units", "\(sticker.currentUnits)"),
            trailing: ("Total Value", totalValue.formatted(.eur)),
            cornerRadius: 10
        )
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button {
                showingAddUnits = true
            } label: {
                Label("Add Units", systemImage: "plus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button {
                showingRemoveUnits = true
            } label: {
                Label("Remove Units", systemImage: "minus.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .tint(.red)
            .disabled(sticker.currentUnits == 0)
        }
    }

    private var historySection: some View {
        let sortedEntries = sticker.logEntries.sorted { $0.date > $1.date }
        let lastID = sortedEntries.last?.id

        return VStack(alignment: .leading, spacing: 0) {
            Text("History")
                .font(.headline)
                .padding(.bottom, 8)

            if sortedEntries.isEmpty {
                Text("No history yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(sortedEntries) { entry in
                        HistoryRowView(entry: entry)
                        if entry.id != lastID {
                            Divider()
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
