import Foundation
import SwiftData
import Testing
@testable import StickerLog

/// Checks the architecture invariants from MAC_SETUP.md against `Sticker.record()`.
@MainActor
struct RecordTests {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try ModelContainer(
            for: Sticker.self, LogEntry.self, Event.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        context = container.mainContext
    }

    private func makeSticker(price: Decimal = 2.5) -> Sticker {
        let sticker = Sticker(name: "Test", unitPrice: price)
        context.insert(sticker)
        return sticker
    }

    private func makeEvent() -> Event {
        let event = Event(name: "Market")
        context.insert(event)
        return event
    }

    @Test func currentUnitsEqualsSumOfQuantityChanges() {
        let sticker = makeSticker()
        sticker.record(10, type: .added)
        sticker.record(-3, type: .sale, event: makeEvent())
        sticker.record(-2, type: .correction)

        #expect(sticker.currentUnits == 5)
        #expect(sticker.logEntries.reduce(0) { $0 + $1.quantityChange } == 5)
    }

    @Test func saleSnapshotsPriceAndEventTotalsUseIt() {
        let sticker = makeSticker(price: 2.5)
        let event = makeEvent()
        sticker.record(10, type: .added)
        sticker.record(-4, type: .sale, event: event)

        sticker.unitPrice = 9  // later price change must not affect past sales

        #expect(event.totalUnitsSold == 4)
        #expect(event.totalValue == 10)
    }

    @Test func correctionIsNeverAttachedToEvent() {
        let sticker = makeSticker()
        let event = makeEvent()
        sticker.record(5, type: .added)
        sticker.record(-1, type: .correction, event: event)

        let correction = sticker.logEntries.first { $0.type == .correction }
        #expect(correction?.event == nil)
        #expect(correction?.priceAtTime == nil)
        #expect(event.logEntries.isEmpty)
    }

    @Test func deletingStickerCascadesToEntries() throws {
        let sticker = makeSticker()
        sticker.record(5, type: .added)
        sticker.record(-2, type: .sale, event: makeEvent())

        context.delete(sticker)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<LogEntry>()) == 0)
    }
}

struct InputParsingTests {
    @Test func priceAcceptsCommaOrPeriod() {
        #expect(Decimal(userInput: "2,5") == Decimal(string: "2.5"))
        #expect(Decimal(userInput: "2.5") == Decimal(string: "2.5"))
        #expect(Decimal(userInput: " 3 ") == 3)
    }

    @Test func priceRejectsJunkInsteadOfReadingAPrefix() {
        #expect(Decimal(userInput: "") == nil)
        #expect(Decimal(userInput: "2abc") == nil)
        #expect(Decimal(userInput: "1.000,50") == nil)
        #expect(Decimal(userInput: "-1") == nil)
        #expect(Decimal(userInput: ".") == nil)
    }

    @Test func priceRoundsToTwoDecimals() {
        #expect(Decimal(userInput: "2.555") == Decimal(string: "2.56"))
        #expect(Decimal(userInput: "2.554") == Decimal(string: "2.55"))
    }

    @Test func priceRoundTripsThroughInputString() {
        let price = Decimal(string: "12.5")!
        #expect(Decimal(userInput: price.inputString) == price)
    }

    @Test func quantityIsBounded() {
        #expect(Int(quantityInput: "0") == 0)
        #expect(Int(quantityInput: " 7 ") == 7)
        #expect(Int(quantityInput: "100000") == 100_000)
        #expect(Int(quantityInput: "100001") == nil)
        #expect(Int(quantityInput: "-1") == nil)
        #expect(Int(quantityInput: "99999999999999999999") == nil)
    }
}
