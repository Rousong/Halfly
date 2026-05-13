import SwiftUI

struct ExpenseRow: View {
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
