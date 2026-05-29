import SwiftUI

struct HistoryRowView: View {
    let entry: LogEntry

    private var signedQuantity: String {
        entry.quantityChange >= 0
            ? "+\(entry.quantityChange)"
            : "−\(abs(entry.quantityChange))"
    }

    private var quantityColor: Color {
        entry.quantityChange >= 0 ? .green : .red
    }

    private var label: String {
        switch entry.type {
        case .added:      return "Added"
        case .sale:       return entry.event?.name ?? "Unknown Event"
        case .correction: return "Correction"
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            Text(signedQuantity)
                .font(.headline)
                .foregroundStyle(quantityColor)
                .monospacedDigit()
                .frame(width: 52, alignment: .trailing)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                Text(entry.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
