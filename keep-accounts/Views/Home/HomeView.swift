import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var currentDate = Date()
    @State private var showAddTransaction = false

    @Query private var allTransactions: [Transaction]

    private var monthTransactions: [Transaction] {
        allTransactions.filter { $0.date.isSameMonth(as: currentDate) }
    }

    private var totalIncome: Decimal {
        monthTransactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var totalExpense: Decimal {
        monthTransactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    private var balance: Decimal { totalIncome - totalExpense }

    private var groupedByDate: [(Date, [Transaction])] {
        let grouped = Dictionary(grouping: monthTransactions) { $0.date.startOfDay }
        return grouped.sorted { $0.key > $1.key }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    VStack(spacing: 16) {
                        // Month picker
                        monthPicker

                        // Summary card
                        summaryCard

                        // Transaction list
                        transactionList
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }

                // FAB
                addButton
            }
            .navigationTitle("账单")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showAddTransaction) {
                AddTransactionView()
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
                if next <= Date() {
                    currentDate = next
                }
            } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(currentDate.isSameMonth(as: Date()))
        }
        .padding(.horizontal, 8)
        .padding(.top, 8)
    }

    // MARK: - Summary Card
    private var summaryCard: some View {
        HStack(spacing: 0) {
            summaryItem(title: "收入", amount: totalIncome, color: .green)
            Divider().frame(height: 40)
            summaryItem(title: "支出", amount: totalExpense, color: .red)
            Divider().frame(height: 40)
            summaryItem(title: "结余", amount: balance, color: .primary)
        }
        .padding(.vertical, 16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private func summaryItem(title: LocalizedStringKey, amount: Decimal, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("¥\(amount.formattedCurrency)")
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Transaction List
    private var transactionList: some View {
        LazyVStack(spacing: 12) {
            if groupedByDate.isEmpty {
                ContentUnavailableView("暂无记录", systemImage: "tray", description: Text("点击右下角按钮开始记账"))
                    .padding(.top, 60)
            }
            ForEach(groupedByDate, id: \.0) { date, transactions in
                Section {
                    ForEach(transactions.sorted(by: { $0.createdAt > $1.createdAt })) { transaction in
                        TransactionRowView(transaction: transaction)
                            .contextMenu {
                                Button(role: .destructive) {
                                    modelContext.delete(transaction)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                }
                            }
                    }
                } header: {
                    HStack {
                        Text(date.shortDateString)
                            .font(.subheadline.bold())
                        Text(date.dayOfWeekString)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.top, 4)
                }
            }
        }
    }

    // MARK: - Add Button
    private var addButton: some View {
        Button {
            showAddTransaction = true
        } label: {
            Image(systemName: "plus")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(.blue, in: Circle())
                .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
        }
        .padding(.trailing, 20)
        .padding(.bottom, 20)
    }
}
