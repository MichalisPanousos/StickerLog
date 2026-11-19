import SwiftUI

/// Two stat cells side by side with a divider, on a rounded background.
struct StatsHeader: View {
    let leading: (label: String, value: String)
    let trailing: (label: String, value: String)
    var cornerRadius: CGFloat = 12

    var body: some View {
        HStack(spacing: 0) {
            cell(leading)
            Divider().frame(height: 36)
            cell(trailing)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: cornerRadius))
    }

    private func cell(_ stat: (label: String, value: String)) -> some View {
        VStack(spacing: 2) {
            Text(stat.value)
                .font(.title3)
                .fontWeight(.semibold)
            Text(stat.label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
