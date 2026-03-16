//
//  keep_accountsApp.swift
//  keep-accounts
//
//  Created by 刘伟华 on 2026/3/16.
//

import SwiftUI
import SwiftData

@main
struct keep_accountsApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            let schema = Schema([
                Transaction.self,
                Category.self,
                Tag.self,
                Budget.self,
            ])
            let config = ModelConfiguration(
                cloudKitDatabase: .automatic
            )
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            PresetCategories.seedIfNeeded(context: modelContainer.mainContext)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
