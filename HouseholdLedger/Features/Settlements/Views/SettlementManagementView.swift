import SwiftUI

struct SettlementManagementView: View {
    @EnvironmentObject private var store: LedgerStore
    @State private var note = ""
    @State private var completedSettlement: Settlement?
    @State private var errorMessage: String?

    private var unsettled: [Expense] {
        store.unsettledSharedExpenses()
    }

    private var summary: LedgerSummary {
        store.summary(for: unsettled)
    }

    var body: some View {
        NavigationStack {
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
                    SettlementMessage(netTransfer: summary.netTransfer)
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
            .navigationTitle("结清管理")
            .alert("结清完成", isPresented: Binding(
                get: { completedSettlement != nil },
                set: { if !$0 { completedSettlement = nil } }
            )) {
                Button("好", role: .cancel) {}
            } message: {
                if let completedSettlement {
                    Text(settlementText(for: completedSettlement.netTransfer))
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
