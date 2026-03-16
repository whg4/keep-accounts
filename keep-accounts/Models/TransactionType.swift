import Foundation

enum TransactionType: String, Codable, CaseIterable, Identifiable {
    case income
    case expense

    var id: String { rawValue }

    var label: String {
        switch self {
        case .income: String(localized: "收入")
        case .expense: String(localized: "支出")
        }
    }
}
