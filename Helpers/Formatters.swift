import Foundation

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    static var eur: Self { .currency(code: "EUR") }
}

extension Decimal {
    /// Parses a typed price. Accepts "," or "." as the decimal separator regardless of locale,
    /// and rejects anything else (letters, signs, grouping separators) instead of reading a prefix.
    init?(userInput: String) {
        let text = userInput
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: ".")
        guard text.contains(where: \.isNumber),
              text.allSatisfy({ $0.isASCII && ($0.isNumber || $0 == ".") }),
              text.filter({ $0 == "." }).count <= 1,
              let value = Decimal(string: text, locale: Locale(identifier: "en_US_POSIX"))
        else { return nil }
        self = value
    }

    /// Price as shown in an editable text field: locale decimal separator, no grouping, 2 decimals.
    /// Always parseable by `Decimal(userInput:)`.
    var inputString: String {
        formatted(.number.grouping(.never).precision(.fractionLength(2)))
    }
}
