import SwiftUI

struct SummarySection: View {
    let summary: LedgerSummary

    var body: some View {
        Section("AA 汇总") {
            MetricRow(title: "AA 总金额", value: yuan(summary.total), systemImage: "sum")
            MetricRow(title: "\(summary.firstParticipantName)垫付", value: yuan(summary.firstParticipantPaid), systemImage: "person")
            MetricRow(title: "\(summary.secondParticipantName)垫付", value: yuan(summary.secondParticipantPaid), systemImage: "person.fill")
        }
    }
}
