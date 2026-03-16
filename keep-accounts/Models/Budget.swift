import Foundation
import SwiftData

@Model
final class Budget {
    var id: UUID
    var amount: Decimal
    var month: Int
    var year: Int

    @Relationship
    var category: Category?

    init(amount: Decimal, month: Int, year: Int, category: Category? = nil) {
        self.id = UUID()
        self.amount = amount
        self.month = month
        self.year = year
        self.category = category
    }
}
