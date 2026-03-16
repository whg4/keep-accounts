import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            if let category = transaction.category {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(Color(hex: category.colorHex))
                    .frame(width: 40, height: 40)
                    .background(Color(hex: category.colorHex).opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: "questionmark.circle")
                    .font(.title3)
                    .foregroundStyle(.gray)
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.12), in: RoundedRectangle(cornerRadius: 10))
            }

            // Info
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.category?.name ?? String(localized: "未分类"))
                    .font(.subheadline.weight(.medium))
                if !transaction.note.isEmpty {
                    Text(transaction.note)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            // Amount
            Text("\(transaction.type == .expense ? "-" : "+")¥\(transaction.amount.formattedCurrency)")
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(transaction.type == .expense ? .red : .green)
        }
        .padding(.vertical, 4)
    }
}
