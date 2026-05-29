import Foundation

extension FormatStyle where Self == Decimal.FormatStyle.Currency {
    static var eur: Self { .currency(code: "EUR") }
}
