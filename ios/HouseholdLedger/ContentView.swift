import SwiftUI

private let sharedCategories = ["水费", "电费", "煤气费", "物业费", "网络费", "房租"]
private let personalCategories = ["购物", "餐饮", "交通", "医疗", "娱乐", "其他"]

struct ContentView: View {
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

private struct AddExpenseView: View {
    @EnvironmentObject private var store: LedgerStore
    @State private var amountText = ""
    @State private var expenseDate = Date()
    @State private var isShared = true
    @State private var category = sharedCategories[0]
    @State private var payer: Payer = .me
    @State private var memo = ""
    @State private var alertMessage: String?

    private var categories: [String] {
        isShared ? sharedCategories : personalCategories
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("支出") {
                    TextField("金额（元）", text: $amountText)
                        .keyboardType(.decimalPad)

                    DatePicker("日期", selection: $expenseDate, displayedComponents: .date)

                    Toggle("AA 平摊", isOn: $isShared)
                        .onChange(of: isShared) { _, newValue in
                            category = newValue ? sharedCategories[0] : personalCategories[0]
                        }

                    Picker("类别", selection: $category) {
                        ForEach(categories, id: \.self) { item in
                            Text(item).tag(item)
                        }
                    }

                    Picker("支付者", selection: $payer) {
                        ForEach(Payer.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("备注（可选）", text: $memo)
                }

                Section {
                    Button {
                        addExpense()
                    } label: {
                        Label("添加支出", systemImage: "plus")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("记录一笔支出")
            .alert("无法添加", isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )) {
                Button("好", role: .cancel) {}
            } message: {
                Text(alertMessage ?? "")
            }
        }
    }

    private func addExpense() {
        guard let amount = parseAmount(), amount > 0 else {
            alertMessage = "请输入大于 0 的金额"
            return
        }

        store.addExpense(
            amount: amount,
            category: category,
            memo: memo,
            expenseDate: expenseDate,
            payer: payer,
            isShared: isShared
        )
        amountText = ""
        memo = ""
        expenseDate = Date()
    }

    private func parseAmount() -> Double? {
        let normalized = amountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }
}

private struct ExpenseListView: View {
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

private struct OverviewView: View {
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

private struct SettlementManagementView: View {
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

private struct SummarySection: View {
    let summary: LedgerSummary

    var body: some View {
        Section("AA 汇总") {
            MetricRow(title: "AA 总金额", value: yuan(summary.total), systemImage: "sum")
            MetricRow(title: "我垫付", value: yuan(summary.mePaid), systemImage: "person")
            MetricRow(title: "老婆垫付", value: yuan(summary.wifePaid), systemImage: "person.fill")
        }
    }
}

private struct RecentSettlementsSection: View {
    @EnvironmentObject private var store: LedgerStore
    var limit: Int?

    private var settlements: [Settlement] {
        let items = store.settlementsForDisplay()
        if let limit {
            return Array(items.prefix(limit))
        }
        return items
    }

    var body: some View {
        Section(limit == nil ? "历史结清记录" : "最近结清记录") {
            if settlements.isEmpty {
                ContentUnavailableView("暂无结清记录", systemImage: "clock")
            } else {
                ForEach(settlements) { settlement in
                    DisclosureGroup {
                        if !settlement.note.isEmpty {
                            Text(settlement.note)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        ForEach(store.settlementExpenses(for: settlement.id)) { expense in
                            ExpenseRow(expense: expense)
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(dateText(settlement.settlementDate)) · 总额 \(yuan(settlement.totalAmount))")
                                .font(.headline)
                            Text(settlementText(for: settlement.netTransfer))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}

private struct ExpenseRow: View {
    let expense: Expense

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(expense.category)
                    .font(.headline)

                Spacer()

                Text(yuan(expense.amount))
                    .font(.headline)
            }

            HStack(spacing: 8) {
                Label(dateText(expense.expenseDate), systemImage: "calendar")
                Text(expense.payer.rawValue)
                Text(expense.isShared ? "AA" : "个人")
                Text(expense.settlementID == nil ? "未结清" : "已结清")
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            if !expense.memo.isEmpty {
                Text(expense.memo)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct MetricRow: View {
    let title: String
    let value: String
    let systemImage: String

    var body: some View {
        HStack {
            Label(title, systemImage: systemImage)
            Spacer()
            Text(value)
                .font(.headline)
        }
    }
}

private struct SettlementMessage: View {
    let netTransfer: Double

    var body: some View {
        Label {
            Text(settlementText(for: netTransfer))
        } icon: {
            Image(systemName: netTransfer == 0 ? "equal.circle" : "arrow.left.arrow.right.circle")
        }
    }
}

private func yuan(_ value: Double) -> String {
    String(format: "%.2f 元", value)
}

private func dateText(_ date: Date) -> String {
    date.formatted(.dateTime.year().month().day())
}

private func settlementText(for netTransfer: Double) -> String {
    if netTransfer > 0 {
        return "老婆需转账给我：\(yuan(netTransfer))"
    }

    if netTransfer < 0 {
        return "我需要转账给老婆：\(yuan(abs(netTransfer)))"
    }

    return "双方持平，无需转账"
}
