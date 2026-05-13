import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var store: LedgerStore

    private var unsettled: [Expense] {
        store.unsettledSharedExpenses()
    }

    private var summary: LedgerSummary {
        store.summary(for: unsettled)
    }

    var body: some View {
        NavigationStack {
            List {
                SummarySection(summary: summary)

                Section("当前结清状态") {
                    SettlementMessage(netTransfer: summary.netTransfer)
                }

                Section("未结清支出") {
                    if unsettled.isEmpty {
                        ContentUnavailableView("暂无未结清的 AA 支出", systemImage: "checkmark.circle")
                    } else {
                        ForEach(unsettled) { expense in
                            ExpenseRow(expense: expense)
                        }
                    }
                }

                RecentSettlementsSection(limit: 5)
            }
            .navigationTitle("概览")
        }
    }
}
