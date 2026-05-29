import SwiftUI

private struct StickerSummary: Identifiable {
    let sticker: Sticker
    let qtySold: Int
    let value: Decimal
    var id: UUID { sticker.id }
}

struct EventDetailView: View {
    let event: Event

    private var totalUnitsSold: Int {
        event.logEntries.reduce(0) { $0 + abs($1.quantityChange) }
    }

    private var totalValue: Decimal {
        event.logEntries.reduce(Decimal(0)) { sum, entry in
            sum + Decimal(abs(entry.quantityChange)) * (entry.priceAtTime ?? 0)
        }
    }

    private var stickerSummaries: [StickerSummary] {
        var dict: [UUID: (Sticker, Int, Decimal)] = [:]
        for entry in event.logEntries {
            guard let sticker = entry.sticker else { continue }
            let qty = abs(entry.quantityChange)
            let entryValue = Decimal(qty) * (entry.priceAtTime ?? 0)
            if let existing = dict[sticker.id] {
                dict[sticker.id] = (existing.0, existing.1 + qty, existing.2 + entryValue)
            } else {
                dict[sticker.id] = (sticker, qty, entryValue)
            }
        }
        return dict.values
            .map { StickerSummary(sticker: $0.0, qtySold: $0.1, value: $0.2) }
            .sorted { $0.sticker.name < $1.sticker.name }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header
                    .padding(.horizontal)

                LazyVStack(spacing: 8) {
                    ForEach(stickerSummaries) { summary in
                        StickerSaleRowView(summary: summary)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 16)
        }
        .navigationTitle(event.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack(spacing: 0) {
            statCell(label: "Units Sold", value: "\(totalUnitsSold)")
            Divider().frame(height: 36)
            statCell(label: "Total Value", value: totalValue.formatted(.currency(code: "EUR")))
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
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
}

private struct StickerSaleRowView: View {
    let summary: StickerSummary

    var body: some View {
        HStack(spacing: 12) {
            photoView
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(summary.sticker.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(summary.qtySold) sold")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(summary.value, format: .currency(code: "EUR"))
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private var photoView: some View {
        if let data = summary.sticker.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray5))
                .overlay {
                    Image(systemName: "photo")
                        .foregroundStyle(.tertiary)
                }
        }
    }
}
