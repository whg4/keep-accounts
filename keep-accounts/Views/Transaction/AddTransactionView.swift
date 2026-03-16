import SwiftUI
import SwiftData

struct AddTransactionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var type: TransactionType = .expense
    @State private var amountText = ""
    @State private var selectedCategory: Category?
    @State private var note = ""
    @State private var date = Date()
    @State private var selectedTags: [Tag] = []
    @State private var showTagPicker = false

    var editingTransaction: Transaction?

    init(editing transaction: Transaction? = nil) {
        self.editingTransaction = transaction
        if let t = transaction {
            _type = State(initialValue: t.type)
            _amountText = State(initialValue: "\(t.amount)")
            _selectedCategory = State(initialValue: t.category)
            _note = State(initialValue: t.note)
            _date = State(initialValue: t.date)
            _selectedTags = State(initialValue: t.tags)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Type picker
                    typePicker

                    // Amount input
                    amountInput

                    // Category picker
                    CategoryPickerView(type: type, selection: $selectedCategory)

                    // Date picker
                    datePicker

                    // Note
                    noteInput

                    // Tags
                    tagSection
                }
                .padding()
            }
            .navigationTitle(editingTransaction == nil ? String(localized: "记一笔") : String(localized: "编辑"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { save() }
                        .bold()
                        .disabled(amountText.isEmpty || selectedCategory == nil)
                }
            }
        }
    }

    // MARK: - Type Picker
    private var typePicker: some View {
        Picker("类型", selection: $type) {
            ForEach(TransactionType.allCases) { t in
                Text(t.label).tag(t)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Amount Input
    private var amountInput: some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("¥")
                    .font(.system(size: 28, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                TextField("0.00", text: $amountText)
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Date Picker
    private var datePicker: some View {
        DatePicker("日期", selection: $date, displayedComponents: .date)
            .datePickerStyle(.compact)
            .padding(.horizontal, 4)
    }

    // MARK: - Note Input
    private var noteInput: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("备注")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
            TextField("添加备注...", text: $note, axis: .vertical)
                .lineLimit(1...3)
                .padding(10)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
    }

    // MARK: - Tags
    private var tagSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("标签")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                Button {
                    showTagPicker = true
                } label: {
                    Image(systemName: "plus.circle")
                }
            }

            if !selectedTags.isEmpty {
                FlowLayout(spacing: 6) {
                    ForEach(selectedTags) { tag in
                        Text(tag.name)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(.blue.opacity(0.1), in: Capsule())
                            .onTapGesture {
                                selectedTags.removeAll { $0.id == tag.id }
                            }
                    }
                }
            }
        }
        .sheet(isPresented: $showTagPicker) {
            TagPickerView(selectedTags: $selectedTags)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Save
    private func save() {
        guard let amount = Decimal(string: amountText), amount > 0 else { return }

        if let existing = editingTransaction {
            existing.amount = amount
            existing.type = type
            existing.category = selectedCategory
            existing.note = note
            existing.date = date
            existing.tags = selectedTags
        } else {
            let transaction = Transaction(
                amount: amount,
                type: type,
                category: selectedCategory,
                note: note,
                tags: selectedTags,
                date: date
            )
            modelContext.insert(transaction)
        }

        dismiss()
    }
}

// MARK: - Flow Layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, subview) in subviews.enumerated() {
            let point = CGPoint(x: bounds.minX + result.positions[index].x,
                                y: bounds.minY + result.positions[index].y)
            subview.place(at: point, anchor: .topLeading, proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
