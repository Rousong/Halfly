import Foundation
import SwiftData

enum LedgerKind: String, CaseIterable, Codable, Identifiable {
    case household = "家庭 AA"
    case travel = "旅行"
    case outing = "出行"
    case gathering = "聚餐"
    case other = "其他"

    var id: String { rawValue }

    var defaultLedgerName: String {
        switch self {
        case .household:
            return "家庭账本"
        case .travel:
            return "旅行账本"
        case .outing:
            return "出行账本"
        case .gathering:
            return "聚餐账本"
        case .other:
            return "其他账本"
        }
    }

    func defaultParticipantNames(count: Int) -> [String] {
        if self == .household && count == 2 {
            return ["我", "老婆"]
        }

        return (1...count).map { "成员\($0)" }
    }
}

@Model
final class Ledger {
    var id: UUID
    var name: String
    var kind: LedgerKind
    var participantNames: [String]
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Expense.ledger)
    var expenses: [Expense]

    @Relationship(deleteRule: .cascade, inverse: \Settlement.ledger)
    var settlements: [Settlement]

    init(
        id: UUID = UUID(),
        name: String,
        kind: LedgerKind,
        participantNames: [String],
        createdAt: Date = Date(),
        expenses: [Expense] = [],
        settlements: [Settlement] = []
    ) {
        self.id = id
        self.name = name
        self.kind = kind
        self.participantNames = participantNames
        self.createdAt = createdAt
        self.expenses = expenses
        self.settlements = settlements
    }

    var participantCount: Int {
        participantNames.count
    }

    var supportsPairSettlement: Bool {
        participantNames.count == 2
    }
}

enum ExpenseFilter: String, CaseIterable, Identifiable {
    case all = "全部"
    case unsettledShared = "未结清"
    case settled = "已结清"
    case personal = "个人"

    var id: String { rawValue }
}

@Model
final class Expense {
    var id: UUID
    var amount: Double
    var category: String
    var memo: String
    var expenseDate: Date
    var payerName: String
    var isShared: Bool
    var createdAt: Date
    var ledger: Ledger?
    var settlement: Settlement?

    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        memo: String,
        expenseDate: Date,
        payerName: String,
        isShared: Bool,
        createdAt: Date = Date(),
        ledger: Ledger? = nil,
        settlement: Settlement? = nil
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.memo = memo
        self.expenseDate = expenseDate
        self.payerName = payerName
        self.isShared = isShared
        self.createdAt = createdAt
        self.ledger = ledger
        self.settlement = settlement
    }

    var settlementID: UUID? {
        settlement?.id
    }
}

@Model
final class Settlement {
    var id: UUID
    var settlementDate: Date
    var note: String
    var totalAmount: Double
    var firstParticipantName: String
    var firstParticipantPaid: Double
    var secondParticipantName: String
    var secondParticipantPaid: Double
    var netTransfer: Double
    var ledger: Ledger?

    @Relationship(deleteRule: .nullify, inverse: \Expense.settlement)
    var expenses: [Expense]

    init(
        id: UUID = UUID(),
        settlementDate: Date = Date(),
        note: String,
        totalAmount: Double,
        firstParticipantName: String,
        firstParticipantPaid: Double,
        secondParticipantName: String,
        secondParticipantPaid: Double,
        netTransfer: Double,
        ledger: Ledger? = nil,
        expenses: [Expense] = []
    ) {
        self.id = id
        self.settlementDate = settlementDate
        self.note = note
        self.totalAmount = totalAmount
        self.firstParticipantName = firstParticipantName
        self.firstParticipantPaid = firstParticipantPaid
        self.secondParticipantName = secondParticipantName
        self.secondParticipantPaid = secondParticipantPaid
        self.netTransfer = netTransfer
        self.ledger = ledger
        self.expenses = expenses
    }
}

struct LedgerSummary: Equatable {
    var total: Double
    var firstParticipantName: String
    var firstParticipantPaid: Double
    var secondParticipantName: String
    var secondParticipantPaid: Double

    var netTransfer: Double {
        ((firstParticipantPaid - secondParticipantPaid) / 2).roundedToCents()
    }
}

extension Double {
    func roundedToCents() -> Double {
        (self * 100).rounded() / 100
    }
}
