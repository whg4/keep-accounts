import SwiftUI
import SwiftData

struct CategoryManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCategories: [Category]
    @State private var selectedType: TransactionType = .expense
    @State private var showAddCategory = false

    private var parentCategories: [Category] {
        allCategories
            .filter { $0.type == selectedType && $0.parent == nil }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    var body: some View {
        List {
            Picker("类型", selection: $selectedType) {
                ForEach(TransactionType.allCases) { t in
                    Text(t.label).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
            .padding(.vertical, 4)

            ForEach(parentCategories) { category in
                Section {
                    categoryRow(category)
                    ForEach(category.children.sorted { $0.sortOrder < $1.sortOrder }) { child in
                        categoryRow(child)
                            .padding(.leading, 20)
                    }
                }
            }
        }
        .navigationTitle("分类管理")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddCategory = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddCategory) {
            AddCategoryView(type: selectedType)
        }
    }

    private func categoryRow(_ category: Category) -> some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .foregroundStyle(Color(hex: category.colorHex))
                .frame(width: 28, height: 28)
                .background(Color(hex: category.colorHex).opacity(0.12), in: RoundedRectangle(cornerRadius: 6))

            Text(category.name)
                .font(.subheadline)

            Spacer()

            if category.isPreset {
                Text("预设")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .swipeActions(edge: .trailing) {
            if !category.isPreset {
                Button(role: .destructive) {
                    modelContext.delete(category)
                } label: {
                    Label("删除", systemImage: "trash")
                }
            }
        }
    }
}

// MARK: - Add Category
struct AddCategoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let type: TransactionType

    @State private var name = ""
    @State private var icon = "tag"
    @State private var colorHex = "4ECDC4"
    @State private var selectedParent: Category?

    @Query private var allCategories: [Category]

    private var parentOptions: [Category] {
        allCategories.filter { $0.type == type && $0.parent == nil }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    private let iconOptions = [
        "tag", "cart", "cup.and.saucer", "fork.knife", "car",
        "house", "book", "gamecontroller", "heart", "star",
        "gift", "phone", "tshirt", "bag", "creditcard",
        "airplane", "figure.run", "music.note", "film", "pills"
    ]

    private let colorOptions = [
        "FF6B6B", "4ECDC4", "45B7D1", "96CEB4", "DDA0DD",
        "FFB347", "87CEEB", "98D8C8", "F7DC6F", "BDC3C7",
        "2ECC71", "F39C12", "3498DB", "9B59B6", "E74C3C"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("基本信息") {
                    TextField("分类名称", text: $name)

                    // Icon picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("图标")
                            .font(.subheadline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(iconOptions, id: \.self) { ic in
                                Image(systemName: ic)
                                    .frame(width: 32, height: 32)
                                    .background(icon == ic ? Color(hex: colorHex).opacity(0.2) : Color.clear, in: RoundedRectangle(cornerRadius: 6))
                                    .onTapGesture { icon = ic }
                            }
                        }
                    }

                    // Color picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("颜色")
                            .font(.subheadline)
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                            ForEach(colorOptions, id: \.self) { c in
                                Circle()
                                    .fill(Color(hex: c))
                                    .frame(width: 28, height: 28)
                                    .overlay {
                                        if colorHex == c {
                                            Image(systemName: "checkmark")
                                                .font(.caption.bold())
                                                .foregroundStyle(.white)
                                        }
                                    }
                                    .onTapGesture { colorHex = c }
                            }
                        }
                    }
                }

                Section("父分类（可选）") {
                    Picker("作为子分类", selection: $selectedParent) {
                        Text("无（顶级分类）").tag(nil as Category?)
                        ForEach(parentOptions) { cat in
                            Text(cat.name).tag(cat as Category?)
                        }
                    }
                }
            }
            .navigationTitle("新建分类")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        let maxOrder = parentOptions.map(\.sortOrder).max() ?? 0
                        let cat = Category(
                            name: name.trimmingCharacters(in: .whitespaces),
                            icon: icon,
                            colorHex: colorHex,
                            type: type,
                            isPreset: false,
                            sortOrder: maxOrder + 1,
                            parent: selectedParent
                        )
                        modelContext.insert(cat)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
