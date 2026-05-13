import Foundation

func yuan(_ value: Double) -> String {
    String(format: "%.2f 元", value)
}

func dateText(_ date: Date) -> String {
    date.formatted(.dateTime.year().month().day())
}

func settlementText(firstParticipantName: String, secondParticipantName: String, netTransfer: Double) -> String {
    if netTransfer > 0 {
        return "\(secondParticipantName)需转账给\(firstParticipantName)：\(yuan(netTransfer))"
    }

    if netTransfer < 0 {
        return "\(firstParticipantName)需转账给\(secondParticipantName)：\(yuan(abs(netTransfer)))"
    }

    return "双方持平，无需转账"
}
