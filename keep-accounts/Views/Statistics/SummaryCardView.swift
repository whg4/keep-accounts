import SwiftUI

struct SummaryCardView: View {
    let transactions: [Transaction]
    let timeScope: StatisticsView.TimeScope
    let date: Date

    private var income: Decimal {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var expense: Decimal {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var balance: Decimal { income - expense }

    private var daysInPeriod: Int {
        switch timeScope {
        case .month:
            let range = Calendar.current.range(of: .day, in: .month, for: date)!
            return range.count
        case .year:
            let range = Calendar.current.range(of: .day, in: .year, for: date)!
            return range.count
        }
    }

    private var dailyAvgExpense: Decimal {
        let days = max(daysInPeriod, 1)
        return expense / Decimal(days)
    }

    private var maxExpense: Transaction? {
        transactions.filter { $0.type == .expense }.max { $0.amount < $1.amount }
    }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 0) {
                statItem(title: "收入", value: "¥\(income.formattedCurrency)", color: .green)
                Divider().frame(height: 40)
                statItem(title: "支出", value: "¥\(expense.formattedCurrency)", color: .red)
                Divider().frame(height: 40)
                statItem(title: "结余", value: "¥\(balance.formattedCurrency)", color: .primary)
            }

            Divider()

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("日均支出")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("¥\(dailyAvgExpense.formattedCurrency)")
                        .font(.subheadline.weight(.medium))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("最大单笔支出")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let max = maxExpense {
                        Text("¥\(max.amount.formattedCurrency)")
                            .font(.subheadline.weight(.medium))
                    } else {
                        Text("-")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func statItem(title: LocalizedStringKey, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}
