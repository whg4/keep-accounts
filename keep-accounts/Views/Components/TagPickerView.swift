import SwiftUI
import SwiftData

struct TagPickerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTags: [Tag]
    @Query private var allTags: [Tag]
    @State private var newTagName = ""

    var body: some View {
        NavigationStack {
            List {
                Section("新建标签") {
                    HStack {
                        TextField("标签名称", text: $newTagName)
                        Button("添加") {
                            guard !newTagName.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            let tag = Tag(name: newTagName.trimmingCharacters(in: .whitespaces))
                            modelContext.insert(tag)
                            selectedTags.append(tag)
                            newTagName = ""
                        }
                        .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }

                Section("已有标签") {
                    ForEach(allTags) { tag in
                        HStack {
                            Text(tag.name)
                            Spacer()
                            if selectedTags.contains(where: { $0.id == tag.id }) {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if let idx = selectedTags.firstIndex(where: { $0.id == tag.id }) {
                                selectedTags.remove(at: idx)
                            } else {
                                selectedTags.append(tag)
                            }
                        }
                    }
                }
            }
            .navigationTitle("选择标签")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") { dismiss() }
                }
            }
        }
    }
}
