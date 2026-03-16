import SwiftUI
import SwiftData

struct CategoryPickerView: View {
    let type: TransactionType
    @Binding var selection: Category?

    @Query private var allCategories: [Category]

    private var parentCategories: [Category] {
        allCategories
            .filter { $0.type == type && $0.parent == nil }
            .sorted { $0.sortOrder < $1.sortOrder }
    }

    @State private var expandedCategory: Category?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分类")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(parentCategories) { category in
                    categoryButton(category)
                }
            }

            // Subcategories
            if let expanded = expandedCategory, !expanded.children.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(expanded.name)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(expanded.children.sorted { $0.sortOrder < $1.sortOrder }) { sub in
                            categoryButton(sub)
                        }
                    }
                }
                .padding(.top, 4)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: expandedCategory?.id)
    }

    private func categoryButton(_ category: Category) -> some View {
        let isSelected = selection?.id == category.id
        return Button {
            if category.parent == nil && !category.children.isEmpty {
                if expandedCategory?.id == category.id {
                    expandedCategory = nil
                } else {
                    expandedCategory = category
                }
            }
            selection = category
        } label: {
            VStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .frame(width: 40, height: 40)
                    .background(
                        isSelected
                        ? Color(hex: category.colorHex).opacity(0.2)
                        : Color.gray.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 10)
                    )
                    .foregroundStyle(isSelected ? Color(hex: category.colorHex) : .secondary)

                Text(category.name)
                    .font(.system(size: 10))
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}
