import SwiftUI

struct RootTabView: View {
    @StateObject private var store: FrameCardStore
    @StateObject private var captureViewModel: CaptureViewModel
    @StateObject private var journalViewModel: JournalViewModel
    @StateObject private var reminderService: ReminderService
    @State private var selectedTab = 0
    @State private var showReminderPrompt = false

    init() {
        let sharedStore = FrameCardStore()
        _store = StateObject(wrappedValue: sharedStore)
        _captureViewModel = StateObject(wrappedValue: CaptureViewModel(store: sharedStore))
        _journalViewModel = StateObject(wrappedValue: JournalViewModel(store: sharedStore))
        _reminderService = StateObject(wrappedValue: ReminderService())
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            CaptureView(viewModel: captureViewModel)
                .tabItem {
                    Label("Capture", systemImage: "camera")
                }
                .tag(0)

            JournalView(
                viewModel: journalViewModel,
                store: store,
                onCaptureCTA: { selectedTab = 0 }
            )
            .tabItem {
                Label("Journal", systemImage: "square.grid.2x2")
            }
            .tag(1)

            NavigationStack {
                MoreHubView(store: store, reminderService: reminderService)
            }
            .tabItem {
                Label("More", systemImage: "ellipsis.circle")
            }
            .tag(2)
        }
        .tint(AppTheme.warmAccent)
        .preferredColorScheme(.dark)
        .onChange(of: captureViewModel.didCompleteSave) { completed in
            guard completed else { return }
            captureViewModel.didCompleteSave = false
            LevelProgressStore.shared.evaluate(using: store.cards)
            maybeAskReminderAfterSave()
        }
        .onChange(of: store.cards) { _ in
            LevelProgressStore.shared.evaluate(using: store.cards)
        }
        .onAppear {
            LevelProgressStore.shared.evaluate(using: store.cards)
        }
        .alert("Daily Reminder", isPresented: $showReminderPrompt) {
            Button("Enable") {
                reminderService.markAskedAfterSave()
                Task {
                    await reminderService.setEnabled(true)
                }
            }
            Button("Not Now", role: .cancel) {
                reminderService.markAskedAfterSave()
            }
        } message: {
            Text("Get a gentle daily nudge to capture today's card.")
        }
    }

    private func maybeAskReminderAfterSave() {
        guard !reminderService.hasAskedAfterSave else { return }
        guard !reminderService.isEnabled else {
            reminderService.markAskedAfterSave()
            return
        }
        showReminderPrompt = true
    }
}
