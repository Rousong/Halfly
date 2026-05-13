import SwiftUI

struct RecentSettlementsSection: View {
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
                            Text(
                                settlementText(
                                    firstParticipantName: settlement.firstParticipantName,
                                    secondParticipantName: settlement.secondParticipantName,
                                    netTransfer: settlement.netTransfer
                                )
                            )
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }
}
