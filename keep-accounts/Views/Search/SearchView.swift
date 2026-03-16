import SwiftUI
import SwiftData

struct SearchView: View {
    @Query private var allTransactions: [Transaction]
    @Query private var allCategories: [Category]

    @State private var searchText = ""
    @State private var selectedType: TransactionType?
    @State private var selectedCategory: Category?
    @State private var startDate: Date?
    @State private var endDate: Date?
    @State private var showFilters = false

    private var results: [Transaction] {
        var filtered = allTransactions

        // Text search
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            filtered = filtered.filter { t in
                t.note.lowercased().contains(query)
                || t.category?.name.lowercased().contains(query) == true
                || t.tags.contains(where: { $0.name.lowercased().contains(query) })
                || "\(t.amount)".contains(query)
            }
        }

        // Type filter
        if let type = selectedType {
            filtered = filtered.filter { $0.type == type }
        }

        // Category filter
        if let cat = selectedCategory {
            filtered = filtered.filter { $0.category?.id == cat.id || $0.category?.parent?.id == cat.id }
        }

        // Date range
        if let start = startDate {
            filtered = filtered.filter { $0.date >= start.startOfDay }
        }
        if let end = endDate {
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: end.startOfDay)!
            filtered = filtered.filter { $0.date < endOfDay }
        }

        return filtered.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filters
                if showFilters {
                    filtersSection
                }

                // Results
                List {
                    if results.isEmpty {
                        ContentUnavailableView.search(text: searchText)
                    } else {
                        Text("\(results.count) 条记录")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .listRowBackground(Color.clear)

                        ForEach(results) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle("搜索")
            .searchable(text: $searchText, prompt: "搜索备注、分类、标签...")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        withAnimation { showFilters.toggle() }
                    } label: {
                        Image(systemName: showFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
            }
        }
    }

    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Type filter
            HStack {
                Text("类型")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("", selection: Binding(
                    get: { selectedType },
                    set: { selectedType = $0 }
                )) {
                    Text("全部").tag(nil as TransactionType?)
                    ForEach(TransactionType.allCases) { t in
                        Text(t.label).tag(t as TransactionType?)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 200)
            }

            // Date range
            HStack {
                Text("日期")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                DatePicker("从", selection: Binding(
                    get: { startDate ?? Date().startOfMonth },
                    set: { startDate = $0 }
                ), displayedComponents: .date)
                .labelsHidden()

                Text("至")
                    .font(.caption)
                DatePicker("到", selection: Binding(
                    get: { endDate ?? Date() },
                    set: { endDate = $0 }
                ), displayedComponents: .date)
                .labelsHidden()
            }

            // Clear filters
            Button("清除筛选") {
                selectedType = nil
                selectedCategory = nil
                startDate = nil
                endDate = nil
            }
            .font(.caption)
        }
        .padding()
        .background(.regularMaterial)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}
