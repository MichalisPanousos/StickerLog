import Foundation
import SwiftData

@Model
final class Sticker {
    var id: UUID
    var name: String
    var photoData: Data?
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
