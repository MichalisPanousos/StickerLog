import SwiftUI

struct StickerCardView: View {
    let sticker: Sticker

    private var totalValue: Decimal {
        Decimal(sticker.currentUnits) * sticker.unitPrice
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            photoView
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(10)

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
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var photoView: some View {
        if let data = sticker.photoData, let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
        } else {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray5))
                .overlay {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                }
        }
    }
}
