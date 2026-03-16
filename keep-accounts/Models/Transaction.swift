import Foundation
import SwiftData

@Model
final class Transaction {
    var id: UUID
    var amount: Decimal
    var type: TransactionType
    var note: String
    var date: Date
    var createdAt: Date

    @Relationship
    var category: Category?

    @Relationship
    var tags: [Tag]

    init(
        amount: Decimal,
        type: TransactionType,
        category: Category? = nil,
        note: String = "",
        tags: [Tag] = [],
        date: Date = .now
    ) {
        self.id = UUID()
        self.amount = amount
        self.type = type
        self.category = category
        self.note = note
        self.tags = tags
        self.date = date
        self.createdAt = .now
    }
}
