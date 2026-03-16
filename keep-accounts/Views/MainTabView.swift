import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("账单", systemImage: "list.bullet.rectangle", value: 0) {
                HomeView()
            }
            Tab("统计", systemImage: "chart.pie", value: 1) {
                StatisticsView()
            }
            Tab("预算", systemImage: "yensign.circle", value: 2) {
                BudgetOverviewView()
            }
            Tab("设置", systemImage: "gearshape", value: 3) {
                SettingsView()
            }
        }
    }
}
