import SwiftUI
import SwiftData

@main
struct HouseholdLedgerApp: App {
    private let modelContainer: ModelContainer
    @StateObject private var store: LedgerStore

    init() {
        do {
            let container = try ModelContainer(for: Ledger.self, Expense.self, Settlement.self)
            modelContainer = container
            _store = StateObject(wrappedValue: LedgerStore(modelContext: container.mainContext))
        } catch {
            fatalError("无法初始化 SwiftData 容器：\(error.localizedDescription)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
        .modelContainer(modelContainer)
    }
}
