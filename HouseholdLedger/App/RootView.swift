import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: LedgerStore
    @State private var isPresentingLedgerSheet = false

    var body: some View {
        TabView {
            LedgerManagementView(isPresentingLedgerSheet: $isPresentingLedgerSheet)
                .tabItem { Label("账本", systemImage: "books.vertical") }

            AddExpenseView()
                .tabItem { Label("记录", systemImage: "plus.circle") }

            ExpenseListView()
                .tabItem { Label("列表", systemImage: "list.bullet") }

            OverviewView()
                .tabItem { Label("概览", systemImage: "chart.pie") }

            SettlementManagementView()
                .tabItem { Label("结清", systemImage: "checkmark.seal") }
        }
        .sheet(isPresented: $isPresentingLedgerSheet) {
            LedgerCreationView()
                .interactiveDismissDisabled(store.ledgers.isEmpty)
        }
        .onAppear {
            if store.currentLedger == nil {
                isPresentingLedgerSheet = true
            }
        }
        .onChange(of: store.currentLedger?.id) { _, newValue in
            if newValue == nil {
                isPresentingLedgerSheet = true
            }
        }
    }
}

private struct LedgerManagementView: View {
    @EnvironmentObject private var store: LedgerStore
    @Binding var isPresentingLedgerSheet: Bool

    private var ledgers: [Ledger] {
        store.ledgers.sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        NavigationStack {
            List {
                if let currentLedger = store.currentLedger {
                    Section("当前账本") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(currentLedger.name)
                                .font(.headline)
                            Text("\(currentLedger.kind.rawValue) · \(currentLedger.participantCount) 人")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(currentLedger.participantNames.joined(separator: "、"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }

                Section("全部账本") {
                    if ledgers.isEmpty {
                        ContentUnavailableView("还没有账本", systemImage: "books.vertical")
                    } else {
                        ForEach(ledgers) { ledger in
                            Button {
                                store.selectLedger(id: ledger.id)
                            } label: {
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(ledger.name)
                                            .foregroundStyle(.primary)
                                        Text("\(ledger.kind.rawValue) · \(ledger.participantCount) 人")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if ledger.id == store.currentLedger?.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.tint)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("账本")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingLedgerSheet = true
                    } label: {
                        Label("新建账本", systemImage: "plus")
                    }
                }
            }
        }
    }
}

private struct LedgerCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: LedgerStore

    @State private var participantCount = 2
    @State private var kind: LedgerKind = .household

    private var previewParticipantNames: [String] {
        kind.defaultParticipantNames(count: participantCount)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("账本人数") {
                    Stepper("这是一个 \(participantCount) 人账本", value: $participantCount, in: 2...12)
                }

                Section("账本性质") {
                    Picker("性质", selection: $kind) {
                        ForEach(LedgerKind.allCases) { item in
                            Text(item.rawValue).tag(item)
                        }
                    }
                    .pickerStyle(.navigationLink)
                }

                Section("成员预览") {
                    Text(previewParticipantNames.joined(separator: "、"))
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        store.createLedger(participantCount: participantCount, kind: kind)
                        dismiss()
                    } label: {
                        Label("创建账本", systemImage: "checkmark")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("新建账本")
            .toolbar {
                if !store.ledgers.isEmpty {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("取消") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
