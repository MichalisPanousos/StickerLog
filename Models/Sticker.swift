import Foundation
import SwiftData

@Model
final class Sticker {
    var id: UUID
    var name: String
    @Attribute(.externalStorage) var photoData: Data?
    var unitPrice: Decimal
    var currentUnits: Int
    var dateCreated: Date

    @Relationship(deleteRule: .cascade, inverse: \LogEntry.sticker)
    var logEntries: [LogEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        photoData: Data? = nil,
        unitPrice: Decimal,
        currentUnits: Int = 0,
        dateCreated: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.photoData = photoData
        self.unitPrice = unitPrice
        self.currentUnits = currentUnits
        self.dateCreated = dateCreated
    }
}

extension Sticker {
    /// The only place that changes `currentUnits`. Keeps it equal to the sum of
    /// `logEntries.quantityChange`, snapshots `unitPrice` on sales, and never attaches
    /// a correction to an event. The sticker must already be inserted into a context.
    func record(_ change: Int, type: LogEntryType, event: Event? = nil) {
        guard let context = modelContext else {
            assertionFailure("record() called on a sticker that is not in a ModelContext")
            return
        }
        guard currentUnits + change >= 0 else {
            assertionFailure("record() would make currentUnits negative")
            return
        }

        let entry = LogEntry(
            quantityChange: change,
            type: type,
            priceAtTime: type == .sale ? unitPrice : nil
        )
        context.insert(entry)
        logEntries.append(entry)
        entry.event = type == .correction ? nil : event
        currentUnits += change

        try? context.save()
    }
}
