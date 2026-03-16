import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTransactions: [Transaction]
    @AppStorage("appLanguage") private var appLanguage: String = ""

    @State private var showExportSheet = false
    @State private var csvURL: URL?

    var body: some View {
        NavigationStack {
            List {
                Section("数据管理") {
                    NavigationLink {
                        CategoryManageView()
                    } label: {
                        Label("分类管理", systemImage: "square.grid.2x2")
                    }

                    NavigationLink {
                        TagManageView()
                    } label: {
                        Label("标签管理", systemImage: "tag")
                    }

                    NavigationLink {
                        SearchView()
                    } label: {
                        Label("搜索记录", systemImage: "magnifyingglass")
                    }
                }

                Section("iCloud 同步") {
                    HStack {
                        Label("同步状态", systemImage: "icloud")
                        Spacer()
                        Text("自动同步")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label("记录总数", systemImage: "doc.text")
                        Spacer()
                        Text("\(allTransactions.count)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("导出") {
                    Button {
                        exportCSV()
                    } label: {
                        Label("导出为 CSV", systemImage: "square.and.arrow.up")
                    }
                }

                Section("语言") {
                    Picker("语言", selection: $appLanguage) {
                        Text("跟随系统").tag("")
                        Text("简体中文").tag("zh-Hans")
                        Text("English").tag("en")
                    }
                }

                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .sheet(isPresented: $showExportSheet) {
                if let url = csvURL {
                    ShareSheet(items: [url])
                }
            }
        }
    }

    private func exportCSV() {
        var csv = String(localized: "csv.header") + "\n"
        let sorted = allTransactions.sorted { $0.date > $1.date }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for t in sorted {
            let dateStr = dateFormatter.string(from: t.date)
            let typeStr = t.type.label
            let catStr = t.category?.name ?? String(localized: "未分类")
            let amountStr = t.amount.formattedCurrency
            let noteStr = t.note.replacingOccurrences(of: ",", with: "，")
            let tagStr = t.tags.map(\.name).joined(separator: "|")
            csv += "\(dateStr),\(typeStr),\(catStr),\(amountStr),\(noteStr),\(tagStr)\n"
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(String(localized: "csv.filename"))
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
        csvURL = tempURL
        showExportSheet = true
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
