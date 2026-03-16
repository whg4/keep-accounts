import SwiftUI
import Charts

struct TrendLineChartView: View {
    let transactions: [Transaction]
    let timeScope: StatisticsView.TimeScope
    let date: Date
    @State private var chartType: ChartDataType = .expense

    enum ChartDataType: String, CaseIterable {
        case income = "收入"
        case expense = "支出"
        case balance = "结余"
    }

    private struct DailyData: Identifiable {
        let id: Int
        let label: String
        let income: Decimal
        let expense: Decimal
        var balance: Decimal { income - expense }
    }

    private var chartData: [DailyData] {
        switch timeScope {
        case .month:
            return monthlyData()
        case .year:
            return yearlyData()
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("收支趋势")
                    .font(.subheadline.bold())
                Spacer()
                Picker("", selection: $chartType) {
                    ForEach(ChartDataType.allCases, id: \.self) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 180)
            }

            if chartData.isEmpty {
                Text("暂无数据")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            } else {
                Chart(chartData) { data in
                    let value: Decimal = {
                        switch chartType {
                        case .income: return data.income
                        case .expense: return data.expense
                        case .balance: return data.balance
                        }
                    }()

                    LineMark(
                        x: .value("时间", data.label),
                        y: .value("金额", value.doubleValue)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(lineColor)

                    AreaMark(
                        x: .value("时间", data.label),
                        y: .value("金额", value.doubleValue)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(lineColor.opacity(0.1))
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let v = value.as(Double.self) {
                                Text("¥\(Int(v))")
                                    .font(.system(size: 9))
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let label = value.as(String.self) {
                                Text(label)
                                    .font(.system(size: 9))
                            }
                        }
                    }
                }
                .frame(height: 200)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private var lineColor: Color {
        switch chartType {
        case .income: .green
        case .expense: .red
        case .balance: .blue
        }
    }

    // MARK: - Data Builders

    private func monthlyData() -> [DailyData] {
        let cal = Calendar.current
        guard let range = cal.range(of: .day, in: .month, for: date) else { return [] }

        return range.compactMap { day -> DailyData? in
            var comp = cal.dateComponents([.year, .month], from: date)
            comp.day = day
            guard let d = cal.date(from: comp) else { return nil }

            let dayTransactions = transactions.filter { $0.date.isSameDay(as: d) }
            let income = dayTransactions.filter { $0.type == .income }.reduce(Decimal.zero) { $0 + $1.amount }
            let expense = dayTransactions.filter { $0.type == .expense }.reduce(Decimal.zero) { $0 + $1.amount }

            return DailyData(id: day, label: "\(day)日", income: income, expense: expense)
        }
    }

    private func yearlyData() -> [DailyData] {
        return (1...12).map { month in
            let monthTransactions = transactions.filter { $0.date.month == month }
            let income = monthTransactions.filter { $0.type == .income }.reduce(Decimal.zero) { $0 + $1.amount }
            let expense = monthTransactions.filter { $0.type == .expense }.reduce(Decimal.zero) { $0 + $1.amount }
            return DailyData(id: month, label: "\(month)月", income: income, expense: expense)
        }
    }
}
