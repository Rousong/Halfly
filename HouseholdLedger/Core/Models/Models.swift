import Foundation

enum Payer: String, CaseIterable, Codable, Identifiable {
    case me = "我"
    case wife = "老婆"

    var id: String { rawValue }
}

enum ExpenseFilter: String, CaseIterable, Identifiable {
    case all = "全部"
    case unsettledShared = "未结清"
    case settled = "已结清"
    case personal = "个人"

    var id: String { rawValue }
}

struct Expense: Identifiable, Codable, Equatable {
    var id: UUID
    var amount: Double
    var category: String
    var memo: String
    var expenseDate: Date
    var payer: Payer
    var isShared: Bool
    var settlementID: UUID?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        amount: Double,
        category: String,
        memo: String,
        expenseDate: Date,
        payer: Payer,
        isShared: Bool,
        settlementID: UUID? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.amount = amount
        self.category = category
        self.memo = memo
        self.expenseDate = expenseDate
        self.payer = payer
        self.isShared = isShared
        self.settlementID = settlementID
        self.createdAt = createdAt
    }
}

struct Settlement: Identifiable, Codable, Equatable {
    var id: UUID
    var settlementDate: Date
    var note: String
    var totalAmount: Double
    var mePaid: Double
    var wifePaid: Double
    var netTransfer: Double

    init(
        id: UUID = UUID(),
        settlementDate: Date = Date(),
        note: String,
        totalAmount: Double,
        mePaid: Double,
        wifePaid: Double,
        netTransfer: Double
    ) {
        self.id = id
        self.settlementDate = settlementDate
        self.note = note
        self.totalAmount = totalAmount
        self.mePaid = mePaid
        self.wifePaid = wifePaid
        self.netTransfer = netTransfer
    }
}

struct LedgerSummary: Equatable {
    var total: Double
    var mePaid: Double
    var wifePaid: Double

    var netTransfer: Double {
        ((mePaid - wifePaid) / 2).roundedToCents()
    }
}

extension Double {
    func roundedToCents() -> Double {
        (self * 100).rounded() / 100
    }
}
