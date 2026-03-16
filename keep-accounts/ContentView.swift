//
//  ContentView.swift
//  keep-accounts
//
//  Created by 刘伟华 on 2026/3/16.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("appLanguage") private var appLanguage: String = ""

    var body: some View {
        MainTabView()
            .environment(\.locale, appLanguage.isEmpty ? .current : Locale(identifier: appLanguage))
    }
}

#Preview {
    ContentView()
}
