import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @State private var timeScope: TimeScope = .month
    @State private var currentDate = Date()

    @Query private var allTransactions: [Transaction]

    enum TimeScope: String, CaseIterable {
        case month = "月度"
        case year = "年度"
    }

    private var filteredTransactions: [Transaction] {
        switch timeScope {
        case .month:
            return allTransactions.filter { $0.date.isSameMonth(as: currentDate) }
        case .year:
            return allTransactions.filter { $0.date.year == currentDate.year }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Scope picker
                    Picker("时间范围", selection: $timeScope) {
                        ForEach(TimeScope.allCases, id: \.self) { s in
                            Text(s.rawValue).tag(s)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Time navigator
                    timeNavigator

                    // Summary card
                    SummaryCardView(transactions: filteredTransactions, timeScope: timeScope, date: currentDate)

                    // Pie chart
                    CategoryPieChartView(transactions: filteredTransactions)

                    // Trend chart
                    TrendLineChartView(
                        transactions: filteredTransactions,
                        timeScope: timeScope,
                        date: currentDate
                    )
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("统计")
        }
    }

    private var timeNavigator: some View {
        HStack {
            Button {
                switch timeScope {
                case .month:
                    currentDate = Calendar.current.date(byAdding: .month, value: -1, to: currentDate)!
                case .year:
                    currentDate = Calendar.current.date(byAdding: .year, value: -1, to: currentDate)!
                }
            } label: {
                Image(systemName: "chevron.left")
            }

            Spacer()

            Text(timeScope == .month ? currentDate.monthYearString : currentDate.yearString)
                .font(.headline)

            Spacer()

            Button {
                switch timeScope {
                case .month:
                    let next = Calendar.current.date(byAdding: .month, value: 1, to: currentDate)!
                    if next <= Date() { currentDate = next }
                case .year:
                    let next = Calendar.current.date(byAdding: .year, value: 1, to: currentDate)!
                    if next.year <= Date().year { currentDate = next }
                }
            } label: {
                Image(systemName: "chevron.right")
            }
        }
        .padding(.horizontal)
    }
}
