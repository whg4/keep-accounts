import SwiftUI
import Charts

struct CategoryPieChartView: View {
    let transactions: [Transaction]
    @State private var selectedType: TransactionType = .expense

    private var filteredTransactions: [Transaction] {
        transactions.filter { $0.type == selectedType }
    }

    private var categoryData: [(Category, Decimal)] {
        var dict: [UUID: (Category, Decimal)] = [:]
        for t in filteredTransactions {
            guard let cat = t.category else { continue }
            let topCat = cat.parent ?? cat
            if let existing = dict[topCat.id] {
                dict[topCat.id] = (existing.0, existing.1 + t.amount)
            } else {
                dict[topCat.id] = (topCat, t.amount)
            }
        }
        return dict.values.sorted { $0.1 > $1.1 }
    }

    private var total: Decimal {
        categoryData.reduce(0) { $0 + $1.1 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("分类占比")
                    .font(.subheadline.bold())
                Spacer()
                Picker("", selection: $selectedType) {
                    ForEach(TransactionType.allCases) { t in
                        Text(t.label).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
            }

            if categoryData.isEmpty {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                Chart(categoryData, id: \.0.id) { item in
                    SectorMark(
                        angle: .value("金额", item.1.doubleValue),
                        innerRadius: .ratio(0.55),
                        angularInset: 1.5
                    )
                    .foregroundStyle(Color(hex: item.0.colorHex))
                }
                .frame(height: 200)

                // Legend
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(categoryData, id: \.0.id) { item in
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color(hex: item.0.colorHex))
                                .frame(width: 8, height: 8)
                            Text(item.0.name)
                                .font(.caption)
                            Spacer()
                            Text(percentage(item.1))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func percentage(_ amount: Decimal) -> String {
        guard total > 0 else { return "0%" }
        let pct = (amount / total * 100).doubleValue
        return String(format: "%.1f%%", pct)
    }
}
