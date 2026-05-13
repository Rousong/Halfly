import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            AddExpenseView()
                .tabItem { Label("记录", systemImage: "plus.circle") }

            ExpenseListView()
                .tabItem { Label("列表", systemImage: "list.bullet") }

            OverviewView()
                .tabItem { Label("概览", systemImage: "chart.pie") }

            SettlementManagementView()
                .tabItem { Label("结清", systemImage: "checkmark.seal") }
        }
    }
}
