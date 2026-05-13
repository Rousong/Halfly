import Foundation
import SwiftData

@MainActor
final class LedgerStore: ObservableObject {
    enum LedgerError: LocalizedError {
        case noUnsettledSharedExpenses
        case noSelectedLedger
        case unsupportedSettlementParticipants

        var errorDescription: String? {
            switch self {
            case .noUnsettledSharedExpenses:
                return "没有可结清的 AA 支出"
            case .noSelectedLedger:
                return "请先创建一个账本"
            case .unsupportedSettlementParticipants:
                return "当前仅支持两人账本结清"
            }
        }
    }

    @Published private(set) var ledgers: [Ledger] = []
    @Published private(set) var selectedLedgerID: UUID?
    @Published private var refreshToken = UUID()

    private let modelContext: ModelContext
    private let userDefaults: UserDefaults
    private let selectedLedgerKey = "selected-ledger-id"

    init(modelContext: ModelContext, userDefaults: UserDefaults = .standard) {
        self.modelContext = modelContext
        self.userDefaults = userDefaults
        if let value = userDefaults.string(forKey: selectedLedgerKey) {
            self.selectedLedgerID = UUID(uuidString: value)
        }
        reloadLedgers()
    }

    var currentLedger: Ledger? {
        guard let selectedLedgerID else {
            return ledgers.first
        }

        return ledgers.first(where: { $0.id == selectedLedgerID }) ?? ledgers.first
    }

    func createLedger(participantCount: Int, kind: LedgerKind) {
        let ledger = Ledger(
            name: nextLedgerName(for: kind),
            kind: kind,
            participantNames: kind.defaultParticipantNames(count: participantCount)
        )
        modelContext.insert(ledger)
        selectedLedgerID = ledger.id
        persistSelection()
        saveAndRefresh()
    }

    func selectLedger(id: UUID) {
        guard ledgers.contains(where: { $0.id == id }) else {
            return
        }

        selectedLedgerID = id
        persistSelection()
        triggerRefresh()
    }

    func addExpense(
        amount: Double,
        category: String,
        memo: String,
        expenseDate: Date,
        payerName: String,
        isShared: Bool
    ) {
        guard let currentLedger else {
            return
        }

        let expense = Expense(
            amount: amount.roundedToCents(),
            category: category,
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines),
            expenseDate: expenseDate,
            payerName: payerName,
            isShared: isShared,
            ledger: currentLedger
        )
        modelContext.insert(expense)
        saveAndRefresh()
    }

    func deleteExpense(id: UUID) {
        guard let expense = expenses(matching: .all).first(where: { $0.id == id }) else {
            return
        }

        modelContext.delete(expense)
        saveAndRefresh()
    }

    func expenses(matching filter: ExpenseFilter) -> [Expense] {
        guard let currentLedger else {
            return []
        }

        let filtered: [Expense]

        switch filter {
        case .all:
            filtered = currentLedger.expenses
        case .unsettledShared:
            filtered = currentLedger.expenses.filter { $0.isShared && $0.settlement == nil }
        case .settled:
            filtered = currentLedger.expenses.filter { $0.settlement != nil }
        case .personal:
            filtered = currentLedger.expenses.filter { !$0.isShared }
        }

        return filtered.sortedForList()
    }

    func unsettledSharedExpenses() -> [Expense] {
        guard let currentLedger else {
            return []
        }

        return currentLedger.expenses
            .filter { $0.isShared && $0.settlement == nil }
            .sorted {
                if $0.expenseDate != $1.expenseDate {
                    return $0.expenseDate < $1.expenseDate
                }
                return $0.createdAt < $1.createdAt
            }
    }

    func settlementExpenses(for settlementID: UUID) -> [Expense] {
        guard let currentLedger else {
            return []
        }

        return currentLedger.expenses
            .filter { $0.settlement?.id == settlementID }
            .sorted {
                if $0.expenseDate != $1.expenseDate {
                    return $0.expenseDate < $1.expenseDate
                }
                return $0.createdAt < $1.createdAt
            }
    }

    func settlementsForDisplay() -> [Settlement] {
        guard let currentLedger else {
            return []
        }

        return currentLedger.settlements.sorted { $0.settlementDate > $1.settlementDate }
    }

    func summary(for expenses: [Expense]) -> LedgerSummary? {
        guard
            let currentLedger,
            currentLedger.supportsPairSettlement
        else {
            return nil
        }

        let firstParticipantName = currentLedger.participantNames[0]
        let secondParticipantName = currentLedger.participantNames[1]
        let shared = expenses.filter(\.isShared)
        let total = shared.reduce(0) { $0 + $1.amount }.roundedToCents()
        let firstPaid = shared
            .filter { $0.payerName == firstParticipantName }
            .reduce(0) { $0 + $1.amount }
            .roundedToCents()
        let secondPaid = shared
            .filter { $0.payerName == secondParticipantName }
            .reduce(0) { $0 + $1.amount }
            .roundedToCents()

        return LedgerSummary(
            total: total,
            firstParticipantName: firstParticipantName,
            firstParticipantPaid: firstPaid,
            secondParticipantName: secondParticipantName,
            secondParticipantPaid: secondPaid
        )
    }

    @discardableResult
    func createSettlement(note: String) throws -> Settlement {
        guard let currentLedger else {
            throw LedgerError.noSelectedLedger
        }

        guard currentLedger.supportsPairSettlement else {
            throw LedgerError.unsupportedSettlementParticipants
        }

        let pending = unsettledSharedExpenses()

        guard !pending.isEmpty else {
            throw LedgerError.noUnsettledSharedExpenses
        }

        guard let summary = summary(for: pending) else {
            throw LedgerError.unsupportedSettlementParticipants
        }

        let settlement = Settlement(
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            totalAmount: summary.total,
            firstParticipantName: summary.firstParticipantName,
            firstParticipantPaid: summary.firstParticipantPaid,
            secondParticipantName: summary.secondParticipantName,
            secondParticipantPaid: summary.secondParticipantPaid,
            netTransfer: summary.netTransfer,
            ledger: currentLedger
        )
        modelContext.insert(settlement)

        for expense in pending {
            expense.settlement = settlement
        }

        saveAndRefresh()
        return settlement
    }

    private func reloadLedgers() {
        var descriptor = FetchDescriptor<Ledger>(
            sortBy: [SortDescriptor(\Ledger.createdAt, order: .reverse)]
        )
        descriptor.includePendingChanges = true
        ledgers = (try? modelContext.fetch(descriptor)) ?? []
        reconcileSelection()
        triggerRefresh()
    }

    private func reconcileSelection() {
        if let selectedLedgerID, ledgers.contains(where: { $0.id == selectedLedgerID }) {
            return
        }

        selectedLedgerID = ledgers.first?.id
        persistSelection()
    }

    private func persistSelection() {
        userDefaults.set(selectedLedgerID?.uuidString, forKey: selectedLedgerKey)
    }

    private func saveAndRefresh() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            assertionFailure("保存账本失败：\(error.localizedDescription)")
        }

        reloadLedgers()
    }

    private func triggerRefresh() {
        refreshToken = UUID()
    }

    private func nextLedgerName(for kind: LedgerKind) -> String {
        let baseName = kind.defaultLedgerName
        let existingCount = ledgers.filter { $0.name.hasPrefix(baseName) }.count
        if existingCount == 0 {
            return baseName
        }
        return "\(baseName) \(existingCount + 1)"
    }
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
