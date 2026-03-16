import SwiftUI
import SwiftData

struct TagManageView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTags: [Tag]
    @State private var newTagName = ""
    @State private var editingTag: Tag?
    @State private var editName = ""

    var body: some View {
        List {
            Section("新建标签") {
                HStack {
                    TextField("标签名称", text: $newTagName)
                    Button("添加") {
                        let name = newTagName.trimmingCharacters(in: .whitespaces)
                        guard !name.isEmpty else { return }
                        modelContext.insert(Tag(name: name))
                        newTagName = ""
                    }
                    .disabled(newTagName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }

            Section("所有标签 (\(allTags.count))") {
                ForEach(allTags) { tag in
                    HStack {
                        if editingTag?.id == tag.id {
                            TextField("名称", text: $editName, onCommit: {
                                tag.name = editName.trimmingCharacters(in: .whitespaces)
                                editingTag = nil
                            })
                        } else {
                            Text(tag.name)
                            Spacer()
                            Text("\(tag.transactions.count) 条记录")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingTag = tag
                        editName = tag.name
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            modelContext.delete(tag)
                        } label: {
                            Label("删除", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("标签管理")
    }
}
