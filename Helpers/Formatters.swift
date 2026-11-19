import Foundation

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    static var eur: Self { .currency(code: "EUR") }
}

extension Decimal {
    /// Parses a typed price. Accepts "," or "." as the decimal separator regardless of locale,
    /// and rejects anything else (letters, signs, grouping separators) instead of reading a prefix.
    /// The result is rounded to 2 decimal places (half up).
    init?(userInput: String) {
        let text = userInput
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard text.contains(where: \.isNumber),
              text.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }),
              text.filter({ $0 == "." }).count <= 1,
              var value = Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
        else { return nil }
        var rounded = Decimal()
        NSDecimalRound(&rounded, &value, 2, .plain)
        self = rounded
    }

    /// Price as shown in an editable text field: locale decimal separator, no grouping, 2 decimals.
    /// Always parseable by `Decimal(userInput:)`.
    var inputString: String {
        formatted(.number.grouping(.never).precision(.fractionLength(2)))
    }
}

extension Int {
    /// Largest quantity accepted in one entry. Keeps `currentUnits` far from Int overflow.
    static let maxStickerQuantity = 100_000

    /// Parses a typed quantity in 0...maxStickerQuantity, ignoring surrounding spaces.
    init?(quantityInput: String) {
        guard let value = Int(quantityInput.trimmingCharacters(in: .whitespaces)),
              (0...Int.maxStickerQuantity).contains(value)
        else { return nil }
        self = value
    }
}

/// Shown under a quantity field whose text isn't a valid quantity.
let invalidQuantityMessage = "Enter a whole number up to \(Int.maxStickerQuantity.formatted())."
