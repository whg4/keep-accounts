import Foundation
import SwiftData

@Model
final class Tag {
    var id: UUID
    var name: String

    @Relationship(inverse: \Transaction.tags)
    var transactions: [Transaction]

    init(name: String) {
        self.id = UUID()
        self.name = name
        self.transactions = []
    }
}
