import SwiftUI

struct ExpenseListView: View {
    @EnvironmentObject private var store: LedgerStore
    @State private var filter: ExpenseFilter = .all

    private var expenses: [Expense] {
        store.expenses(matching: filter)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Picker("筛选", selection: $filter) {
                        ForEach(ExpenseFilter.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                SummarySection(summary: store.summary(for: expenses))

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
            .navigationTitle("支出列表")
        }
    }
}
