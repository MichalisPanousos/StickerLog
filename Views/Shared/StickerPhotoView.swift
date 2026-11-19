import SwiftUI

/// Sticker photo, or a gray placeholder. Fills whatever frame the caller gives it and clips to it,
/// so wide or tall photos never push the layout past that frame.
struct StickerPhotoView: View {
    let data: Data?
    var cornerRadius: CGFloat = 0
    var placeholderFont: Font = .body

    var body: some View {
        Color(.systemGray5)
            .overlay {
                if let data, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "photo")
                        .font(placeholderFont)
                        .foregroundStyle(.tertiary)
                }
            }
            .clipShape(.rect(cornerRadius: cornerRadius))
    }
}
