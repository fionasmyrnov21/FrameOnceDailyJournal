import SwiftUI

struct RemindersView: View {
    @ObservedObject var reminderService: ReminderService

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                SectionCard(title: "Daily Reminder", systemImage: "bell") {
                    Toggle(
                        "Enable Reminder",
                        isOn: Binding(
                            get: { reminderService.isEnabled },
                            set: { newValue in
                                Task {
                                    await reminderService.setEnabled(newValue)
                                }
                            }
                        )
                    )
                    .tint(AppTheme.warmAccent)
                    .foregroundStyle(AppTheme.parchment)

                    DatePicker(
                        "Time",
                        selection: $reminderService.reminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .tint(AppTheme.warmAccent)
                    .foregroundStyle(AppTheme.parchment)
                    .disabled(!reminderService.isEnabled)

                    HStack {
                        Text("Status")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                        Spacer()
                        Text(reminderService.statusLabel)
                            .font(AppTheme.chromeFont(14, weight: .semibold))
                            .foregroundStyle(AppTheme.parchment)
                    }

                    if reminderService.authorizationStatus == .denied {
                        Button("Open Settings") {
                            reminderService.openSystemSettings()
                        }
                        .font(AppTheme.chromeFont(15, weight: .semibold))
                        .foregroundStyle(AppTheme.graphite)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppTheme.warmAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    }
                }

                Text("One gentle nudge each day to capture a single frame.")
                    .font(AppTheme.chromeFont(14))
                    .foregroundStyle(AppTheme.mist)
            }
            .padding(20)
        }
        .background {
            AppBackground()
        }
        .navigationTitle("Reminders")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            reminderService.refreshAuthorizationStatus()
        }
    }
}
