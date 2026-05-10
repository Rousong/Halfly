import Foundation

@MainActor
final class LedgerStore: ObservableObject {
    enum LedgerError: LocalizedError {
        case noUnsettledSharedExpenses

        var errorDescription: String? {
            switch self {
            case .noUnsettledSharedExpenses:
                return "没有可结清的 AA 支出"
            }
        }
    }

    @Published private(set) var expenses: [Expense]
    @Published private(set) var settlements: [Settlement]

    private let storageURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(storageURL: URL? = nil) {
        self.storageURL = storageURL ?? Self.defaultStorageURL()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601

        let snapshot = Self.loadSnapshot(from: self.storageURL, decoder: self.decoder)
        self.expenses = snapshot.expenses
        self.settlements = snapshot.settlements
    }

    func addExpense(
        amount: Double,
        category: String,
        memo: String,
        expenseDate: Date,
        payer: Payer,
        isShared: Bool
    ) {
        let expense = Expense(
            amount: amount.roundedToCents(),
            category: category,
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines),
            expenseDate: expenseDate,
            payer: payer,
            isShared: isShared
        )
        expenses.append(expense)
        save()
    }

    func deleteExpense(id: Expense.ID) {
        expenses.removeAll { $0.id == id }
        save()
    }

    func expenses(matching filter: ExpenseFilter) -> [Expense] {
        let filtered: [Expense]

        switch filter {
        case .all:
            filtered = expenses
        case .unsettledShared:
            filtered = expenses.filter { $0.isShared && $0.settlementID == nil }
        case .settled:
            filtered = expenses.filter { $0.settlementID != nil }
        case .personal:
            filtered = expenses.filter { !$0.isShared }
        }

        return filtered.sortedForList()
    }

    func unsettledSharedExpenses() -> [Expense] {
        expenses
            .filter { $0.isShared && $0.settlementID == nil }
            .sorted {
                if $0.expenseDate != $1.expenseDate {
                    return $0.expenseDate < $1.expenseDate
                }
                return $0.createdAt < $1.createdAt
            }
    }

    func settlementExpenses(for settlementID: Settlement.ID) -> [Expense] {
        expenses
            .filter { $0.settlementID == settlementID }
            .sorted {
                if $0.expenseDate != $1.expenseDate {
                    return $0.expenseDate < $1.expenseDate
                }
                return $0.createdAt < $1.createdAt
            }
    }

    func settlementsForDisplay() -> [Settlement] {
        settlements.sorted { $0.settlementDate > $1.settlementDate }
    }

    func summary(for expenses: [Expense]) -> LedgerSummary {
        let shared = expenses.filter(\.isShared)
        let total = shared.reduce(0) { $0 + $1.amount }.roundedToCents()
        let mePaid = shared.filter { $0.payer == .me }.reduce(0) { $0 + $1.amount }.roundedToCents()
        let wifePaid = shared.filter { $0.payer == .wife }.reduce(0) { $0 + $1.amount }.roundedToCents()
        return LedgerSummary(total: total, mePaid: mePaid, wifePaid: wifePaid)
    }

    @discardableResult
    func createSettlement(note: String) throws -> Settlement {
        let pending = unsettledSharedExpenses()

        guard !pending.isEmpty else {
            throw LedgerError.noUnsettledSharedExpenses
        }

        let summary = summary(for: pending)
        let settlement = Settlement(
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            totalAmount: summary.total,
            mePaid: summary.mePaid,
            wifePaid: summary.wifePaid,
            netTransfer: summary.netTransfer
        )
        let pendingIDs = Set(pending.map(\.id))

        expenses = expenses.map { expense in
            var updated = expense
            if pendingIDs.contains(expense.id) {
                updated.settlementID = settlement.id
            }
            return updated
        }
        settlements.append(settlement)
        save()

        return settlement
    }

    private static func defaultStorageURL() -> URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("household-ledger.json")
    }

    private static func loadSnapshot(from url: URL, decoder: JSONDecoder) -> LedgerSnapshot {
        guard let data = try? Data(contentsOf: url) else {
            return LedgerSnapshot(expenses: [], settlements: [])
        }

        return (try? decoder.decode(LedgerSnapshot.self, from: data)) ?? LedgerSnapshot(expenses: [], settlements: [])
    }

    private func save() {
        do {
            let snapshot = LedgerSnapshot(expenses: expenses, settlements: settlements)
            let data = try encoder.encode(snapshot)
            try FileManager.default.createDirectory(
                at: storageURL.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try data.write(to: storageURL, options: .atomic)
        } catch {
            assertionFailure("保存账本失败：\(error.localizedDescription)")
        }
    }
}

private struct LedgerSnapshot: Codable {
    var expenses: [Expense]
    var settlements: [Settlement]
}

private extension Array where Element == Expense {
    func sortedForList() -> [Expense] {
        sorted {
            if $0.expenseDate != $1.expenseDate {
                return $0.expenseDate > $1.expenseDate
            }
            return $0.createdAt > $1.createdAt
        }
    }
}
