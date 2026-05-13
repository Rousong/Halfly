import SwiftUI

struct SettlementManagementView: View {
    @EnvironmentObject private var store: LedgerStore
    @State private var note = ""
    @State private var completedSettlement: Settlement?
    @State private var errorMessage: String?

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
                            Section("待结清支出") {
                                if unsettled.isEmpty {
                                    ContentUnavailableView("暂无未结清的 AA 支出", systemImage: "checkmark.circle")
                                } else {
                                    ForEach(unsettled) { expense in
                                        ExpenseRow(expense: expense)
                                    }
                                }
                            }

                            SummarySection(summary: summary)

                            Section("结清计算") {
                                SettlementMessage(
                                    text: settlementText(
                                        firstParticipantName: summary.firstParticipantName,
                                        secondParticipantName: summary.secondParticipantName,
                                        netTransfer: summary.netTransfer
                                    ),
                                    isBalanced: summary.netTransfer == 0
                                )
                                TextField("结清备注（可选）", text: $note)

                                Button {
                                    settle()
                                } label: {
                                    Label("确认结清", systemImage: "checkmark")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                                .disabled(unsettled.isEmpty)
                            }

                            RecentSettlementsSection()
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
                                    "当前仅支持两人账本结清",
                                    systemImage: "person.2"
                                )
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("请先创建账本", systemImage: "books.vertical")
                }
            }
            .navigationTitle(currentLedger?.name ?? "结清管理")
            .alert("结清完成", isPresented: Binding(
                get: { completedSettlement != nil },
                set: { if !$0 { completedSettlement = nil } }
            )) {
                Button("好", role: .cancel) {}
            } message: {
                if let completedSettlement {
                    Text(
                        settlementText(
                            firstParticipantName: completedSettlement.firstParticipantName,
                            secondParticipantName: completedSettlement.secondParticipantName,
                            netTransfer: completedSettlement.netTransfer
                        )
                    )
                }
            }
            .alert("无法结清", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("好", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func settle() {
        do {
            completedSettlement = try store.createSettlement(note: note)
            note = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
