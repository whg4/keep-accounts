import SwiftUI
import SwiftData

struct BudgetOverviewView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDate = Date()
    @State private var showAddBudget = false

    @Query private var allBudgets: [Budget]
    @Query private var allTransactions: [Transaction]

    private var monthBudgets: [Budget] {
        allBudgets.filter { $0.month == currentDate.month && $0.year == currentDate.year }
    }

    private var totalBudget: Budget? {
        monthBudgets.first { $0.category == nil }
    }

    private var categoryBudgets: [Budget] {
        monthBudgets.filter { $0.category != nil }
    }

    private var monthExpenses: [Transaction] {
        allTransactions.filter { $0.type == .expense && $0.date.isSameMonth(as: currentDate) }
    }

    private var totalSpent: Decimal {
        monthExpenses.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    monthPicker
                    totalBudgetCard
                    categoryBudgetList
                }
                .padding()
            }
            .navigationTitle("预算")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddBudget = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBudget) {
                BudgetSettingView(month: currentDate.month, year: currentDate.year)
            }
        }
    }

    // MARK: - Month Picker
    private var monthPicker: some View {
        HStack {
            Button {
                currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
            } label: {
                Image(systemName: "chevron.left")
            }
            Spacer()
            Text(currentDate.monthYearString)
                .font(.headline)
            Spacer()
            Button {
                let next = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
                if next <= Date() { currentDate = next }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(currentDate.isSameMonth(as: Date()))
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Total Budget Card
    private var totalBudgetCard: some View {
        VStack(spacing: 16) {
            if let budget = totalBudget {
                let ratio = budget.amount > 0 ? (totalSpent / budget.amount).doubleValue : 0
                let isOverBudget = totalSpent > budget.amount

                Text("总预算")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.15), lineWidth: 12)
                    Circle()
                        .trim(from: 0, to: min(CGFloat(ratio), 1.0))
                        .stroke(
                            isOverBudget ? Color.red : Color.blue,
                            style: StrokeStyle(lineWidth: 12, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: ratio)

                    VStack(spacing: 2) {
                        Text("¥\(totalSpent.formattedCurrency)")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundStyle(isOverBudget ? .red : .primary)
                        Text("/ ¥\(budget.amount.formattedCurrency)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(width: 160, height: 160)

                if isOverBudget {
                    Label("已超支 ¥\((totalSpent - budget.amount).formattedCurrency)", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.red)
                } else {
                    Text("剩余 ¥\((budget.amount - totalSpent).formattedCurrency)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                ContentUnavailableView("未设置总预算", systemImage: "yensign.circle", description: Text("点击右上角 + 设置预算"))
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Category Budget List
    private var categoryBudgetList: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !categoryBudgets.isEmpty {
                Text("分类预算")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)

                ForEach(categoryBudgets) { budget in
                    if let category = budget.category {
                        let spent = monthExpenses
                            .filter { $0.category?.id == category.id }
                            .reduce(Decimal.zero) { $0 + $1.amount }
                        let ratio = budget.amount > 0 ? (spent / budget.amount).doubleValue : 0
                        let isOver = spent > budget.amount

                        HStack(spacing: 12) {
                            Image(systemName: category.icon)
                                .foregroundStyle(Color(hex: category.colorHex))
                                .frame(width: 32, height: 32)
                                .background(Color(hex: category.colorHex).opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(category.name)
                                        .font(.subheadline.weight(.medium))
                                    Spacer()
                                    Text("¥\(spent.formattedCurrency) / ¥\(budget.amount.formattedCurrency)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(Color.gray.opacity(0.15))
                                        RoundedRectangle(cornerRadius: 3)
                                            .fill(isOver ? Color.red : Color(hex: category.colorHex))
                                            .frame(width: geo.size.width * min(CGFloat(ratio), 1.0))
                                    }
                                }
                                .frame(height: 6)
                            }
                        }
                    }
                }
            }
        }
    }
}
