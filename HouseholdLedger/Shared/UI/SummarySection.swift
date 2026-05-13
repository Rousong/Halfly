import SwiftUI

struct SummarySection: View {
    let summary: LedgerSummary

    var body: some View {
        Section("AA 汇总") {
            MetricRow(title: "AA 总金额", value: yuan(summary.total), systemImage: "sum")
            MetricRow(title: "我垫付", value: yuan(summary.mePaid), systemImage: "person")
            MetricRow(title: "老婆垫付", value: yuan(summary.wifePaid), systemImage: "person.fill")
        }
    }
}
