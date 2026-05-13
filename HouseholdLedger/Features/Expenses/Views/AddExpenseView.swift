import SwiftUI

private let sharedCategories = ["水费", "电费", "煤气费", "物业费", "网络费", "房租"]
private let personalCategories = ["购物", "餐饮", "交通", "医疗", "娱乐", "其他"]

struct AddExpenseView: View {
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
