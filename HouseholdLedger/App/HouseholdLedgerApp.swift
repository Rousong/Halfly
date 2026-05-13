import SwiftUI

@main
struct HouseholdLedgerApp: App {
    @StateObject private var store = LedgerStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
