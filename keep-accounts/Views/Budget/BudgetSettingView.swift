import SwiftUI
import SwiftData

struct BudgetSettingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let month: Int
    let year: Int

    @State private var totalAmountText = ""
    @State private var categoryBudgets: [(Category, String)] = []

    @Query private var allCategories: [Category]
    @Query private var existingBudgets: [Budget]

    private var expenseParents: [Category] {
        allCategories
            .filter { $0.type == .expense && $0.parent == nil }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("总预算") {
                    HStack {
                        Text("¥")
                        TextField("月度总预算", text: $totalAmountText)
                            .keyboardType(.decimalPad)
                    }
                }

                Section("分类预算（可选）") {
                    ForEach(Array(categoryBudgets.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 12) {
                            Image(systemName: item.0.icon)
                                .foregroundStyle(Color(hex: item.0.colorHex))
                                .frame(width: 28)
                            Text(item.0.name)
                                .font(.subheadline)
                            Spacer()
                            TextField("金额", text: $categoryBudgets[index].1)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                    }
                }
            }
            .navigationTitle("设置预算")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                }
            }
            .onAppear { loadExisting() }
        }
    }

    private func loadExisting() {
        let existing = existingBudgets.filter { $0.month == month && $0.year == year }
        if let total = existing.first(where: { $0.category == nil }) {
            totalAmountText = "\(total.amount)"
        }

        categoryBudgets = expenseParents.map { cat in
            let amount = existing.first { $0.category?.id == cat.id }?.amount
            return (cat, amount.map { "\($0)" } ?? "")
        }
    }

    private func save() {
        // Remove old budgets for this month
        let old = existingBudgets.filter { $0.month == month && $0.year == year }
        for b in old { modelContext.delete(b) }

        // Total budget
        if let total = Decimal(string: totalAmountText), total > 0 {
            modelContext.insert(Budget(amount: total, month: month, year: year))
        }

        // Category budgets
        for (cat, amountStr) in categoryBudgets {
            if let amount = Decimal(string: amountStr), amount > 0 {
                modelContext.insert(Budget(amount: amount, month: month, year: year, category: cat))
            }
        }

        dismiss()
    }
}
