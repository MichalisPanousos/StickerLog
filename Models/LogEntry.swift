import Foundation
import SwiftData

@Model
final class LogEntry {
    var id: UUID
    var quantityChange: Int
    var date: Date
    var type: LogEntryType
    var priceAtTime: Decimal?
    var sticker: Sticker?
    var event: Event?

    init(
        id: UUID = UUID(),
        quantityChange: Int,
        date: Date = Date(),
        type: LogEntryType,
        priceAtTime: Decimal? = nil,
        sticker: Sticker? = nil,
        event: Event? = nil
    ) {
        self.id = id
        self.quantityChange = quantityChange
        self.date = date
        self.type = type
        self.priceAtTime = priceAtTime
        self.sticker = sticker
        self.event = event
    }
}
