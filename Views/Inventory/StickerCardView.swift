import SwiftUI

struct StickerCardView: View {
    let sticker: Sticker

    private var totalValue: Decimal {
        Decimal(sticker.currentUnits) * sticker.unitPrice
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            StickerPhotoView(data: sticker.photoData, cornerRadius: 10, placeholderFont: .largeTitle)
                .aspectRatio(1, contentMode: .fit)

            Text(sticker.name)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)

            Text("\(sticker.currentUnits) units")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(totalValue, format: .eur)
                .font(.caption)
                .foregroundStyle(.primary)
        }
        .padding(10)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
    }
}
