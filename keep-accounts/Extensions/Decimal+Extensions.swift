import Foundation

extension Decimal {
    var formattedCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter.string(from: self as NSDecimalNumber) ?? "0.00"
    }

    var formattedCurrencyWithSign: String {
        if self >= 0 {
            return "+¥\(formattedCurrency)"
        } else {
            return "-¥\(abs.formattedCurrency)"
        }
    }

    var abs: Decimal {
        self < 0 ? -self : self
    }

    var doubleValue: Double {
        NSDecimalNumber(decimal: self).doubleValue
    }
}
