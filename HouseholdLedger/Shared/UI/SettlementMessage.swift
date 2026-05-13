import SwiftUI

struct SettlementMessage: View {
    let text: String
    let isBalanced: Bool

    var body: some View {
        Label {
            Text(text)
        } icon: {
            Image(systemName: isBalanced ? "equal.circle" : "arrow.left.arrow.right.circle")
        }
    }
}
