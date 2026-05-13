import SwiftUI

struct SettlementMessage: View {
    let netTransfer: Double

    var body: some View {
        Label {
            Text(settlementText(for: netTransfer))
        } icon: {
            Image(systemName: netTransfer == 0 ? "equal.circle" : "arrow.left.arrow.right.circle")
        }
    }
}
