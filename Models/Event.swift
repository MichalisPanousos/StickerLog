import Foundation
import SwiftData

@Model
final class Event {
    var id: UUID
    var name: String
    var dateCreated: Date

    @Relationship(inverse: \LogEntry.event)
    var logEntries: [LogEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        dateCreated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.dateCreated = dateCreated
    }
}

extension Event {
    /// Sales that still belong to a sticker. Matches the per-sticker rows in EventDetailView.
    private var sales: [LogEntry] {
        logEntries.filter { $0.sticker != nil }
    }

    var totalUnitsSold: Int {
        sales.reduce(0) { $0 + abs($1.quantityChange) }
    }

    /// Uses the price snapshotted at sale time, never the sticker's current unitPrice.
    var totalValue: Decimal {
        sales.reduce(Decimal(0)) { sum, entry in
            sum + Decimal(abs(entry.quantityChange)) * (entry.priceAtTime ?? 0)
        }
    }
}
