import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject private var store: LedgerStore
    @State private var filter: ExpenseFilter = .all

    private var currentLedger: Ledger? {
        store.currentLedger
    }

    private var expenses: [Expense] {
        store.expenses(matching: filter)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let currentLedger {
                    List {
                        Section("当前账本") {
                            Text(currentLedger.name)
                            Text("\(currentLedger.kind.rawValue) · \(currentLedger.participantCount) 人")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Section {
                            Picker("筛选", selection: $filter) {
                                ForEach(ExpenseFilter.allCases) { item in
                                    Text(item.rawValue).tag(item)
                                }
                            }
                            .pickerStyle(.segmented)
                        }

                        if let summary = store.summary(for: expenses) {
                            SummarySection(summary: summary)
                        }

                        Section("支出记录") {
                            if expenses.isEmpty {
                                ContentUnavailableView("暂无记录", systemImage: "tray")
                            } else {
                                ForEach(expenses) { expense in
                                    ExpenseRow(expense: expense)
                                        .swipeActions {
                                            Button(role: .destructive) {
                                                store.deleteExpense(id: expense.id)
                                            } label: {
                                                Label("删除", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                        }
                    }
                } else {
                    ContentUnavailableView("请先创建账本", systemImage: "books.vertical")
                }
            }
            .navigationTitle(currentLedger?.name ?? "支出列表")
        }
    }
}
