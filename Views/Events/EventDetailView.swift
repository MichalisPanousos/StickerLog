import SwiftUI

private struct StickerSummary: Identifiable {
    let sticker: Sticker
    let qtySold: Int
    let value: Decimal
    var id: UUID { sticker.id }
}

struct EventDetailView: View {
    let event: Event

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
                StatsHeader(
                    leading: ("Units Sold", "\(event.totalUnitsSold)"),
                    trailing: ("Total Value", event.totalValue.formatted(.eur))
                )
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
}

private struct StickerSaleRowView: View {
    let summary: StickerSummary

    var body: some View {
        HStack(spacing: 12) {
            StickerPhotoView(data: summary.sticker.photoData, cornerRadius: 8)
                .frame(width: 56, height: 56)

            VStack(alignment: .leading, spacing: 2) {
                Text(summary.sticker.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text("\(summary.qtySold) sold")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(summary.value, format: .eur)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
    }
}
