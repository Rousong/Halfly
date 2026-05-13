import Foundation

func yuan(_ value: Double) -> String {
    String(format: "%.2f 元", value)
}

func dateText(_ date: Date) -> String {
    date.formatted(.dateTime.year().month().day())
}

func settlementText(for netTransfer: Double) -> String {
    if netTransfer > 0 {
        return "老婆需转账给我：\(yuan(netTransfer))"
    }

    if netTransfer < 0 {
        return "我需要转账给老婆：\(yuan(abs(netTransfer)))"
    }

    return "双方持平，无需转账"
}
