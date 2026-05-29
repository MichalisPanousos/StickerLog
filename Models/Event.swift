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
