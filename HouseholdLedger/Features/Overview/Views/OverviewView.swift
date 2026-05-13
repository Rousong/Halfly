import SwiftUI

struct OverviewView: View {
    @EnvironmentObject private var store: LedgerStore

    private var currentLedger: Ledger? {
        store.currentLedger
    }

    private var unsettled: [Expense] {
        store.unsettledSharedExpenses()
    }

    private var summary: LedgerSummary? {
        store.summary(for: unsettled)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let currentLedger {
                    if let summary {
                        List {
                            SummarySection(summary: summary)

                            Section("当前结清状态") {
                                SettlementMessage(
                                    text: settlementText(
                                        firstParticipantName: summary.firstParticipantName,
                                        secondParticipantName: summary.secondParticipantName,
                                        netTransfer: summary.netTransfer
                                    ),
                                    isBalanced: summary.netTransfer == 0
                                )
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
                    } else {
                        List {
                            Section("当前账本") {
                                Text(currentLedger.name)
                                Text("\(currentLedger.kind.rawValue) · \(currentLedger.participantCount) 人")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Section {
                                ContentUnavailableView(
                                    "多人账本暂不提供双人 AA 概览",
                                    systemImage: "person.3"
                                )
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("请先创建账本", systemImage: "books.vertical")
                }
            }
            .navigationTitle(currentLedger?.name ?? "概览")
        }
    }
}
