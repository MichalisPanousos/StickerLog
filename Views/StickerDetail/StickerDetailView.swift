import SwiftUI
import SwiftData

struct StickerDetailView: View {
    @Bindable var sticker: Sticker
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var unitPriceText = ""
    @State private var showingDeleteConfirm = false
    @State private var showingAddUnits = false
    @State private var showingRemoveUnits = false

    private var totalValue: Decimal {
        Decimal(sticker.currentUnits) * sticker.unitPrice
    }

    private var sortedEntries: [LogEntry] {
        sticker.logEntries.sorted { $0.date > $1.date }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                photoView
                    .frame(maxWidth: .infinity)
                    .frame(height: 280)
                    .clipped()
                    .cornerRadius(14)

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
        }
        .onAppear {
            unitPriceText = sticker.unitPrice.description
        }
        .confirmationDialog(
            "Delete this sticker? This removes it and its history permanently.",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete Sticker", role: .destructive) {
                modelContext.delete(sticker)
                dismiss()
            }
        }
        .sheet(isPresented: $showingAddUnits) {
            AddUnitsView(sticker: sticker)
        }
        .sheet(isPresented: $showingRemoveUnits) {
            RemoveUnitsView(sticker: sticker)
        }
    }

    @ViewBuilder
    private var photoView: some View {
        if let data = sticker.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color(.systemGray5))
                .overlay {
                    Image(systemName: "photo")
                        .font(.system(size: 48))
                        .foregroundStyle(.tertiary)
                }
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
                    .onChange(of: unitPriceText) { _, newValue in
                        if let price = Decimal(string: newValue, locale: .current) {
                            sticker.unitPrice = price
                        }
                    }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statCell(label: "Units", value: "\(sticker.currentUnits)")
            Divider().frame(height: 36)
            statCell(label: "Total Value", value: totalValue.formatted(.eur))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    private func statCell(label: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
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
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 0) {
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
                        if entry.id != sortedEntries.last?.id {
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
