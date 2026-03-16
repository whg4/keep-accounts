import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var type: TransactionType
    var isPreset: Bool
    var sortOrder: Int

    @Relationship(inverse: \Category.children)
    var parent: Category?

    @Relationship
    var children: [Category]

    @Relationship(inverse: \Transaction.category)
    var transactions: [Transaction]

    init(
        name: String,
        icon: String,
        colorHex: String,
        type: TransactionType,
        isPreset: Bool = false,
        sortOrder: Int = 0,
        parent: Category? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.type = type
        self.isPreset = isPreset
        self.sortOrder = sortOrder
        self.parent = parent
        self.children = []
        self.transactions = []
    }
}
