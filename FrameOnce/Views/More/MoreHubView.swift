import SwiftUI

struct MoreHubView: View {
    let store: FrameCardStore
    @ObservedObject var reminderService: ReminderService

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                NavigationLink {
                    ProfileView()
                } label: {
                    SectionCard(title: "Profile", systemImage: "person.crop.circle") {
                        Text("Set your name and capture a profile photo.")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)

                NavigationLink {
                    LevelsView(store: store)
                } label: {
                    SectionCard(title: "Levels", systemImage: "flag") {
                        Text("Progress through quiet journal milestones.")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)

                NavigationLink {
                    AtmosphereStudioView(viewModel: AtmosphereViewModel(store: store))
                } label: {
                    SectionCard(title: "Studio", systemImage: "paintpalette") {
                        Text("Tune atmospheres and set your preferred look.")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)

                NavigationLink {
                    WeekGlanceView(viewModel: WeekGlanceViewModel(store: store), store: store)
                } label: {
                    SectionCard(title: "Week", systemImage: "calendar") {
                        Text("Glance across the week as film strips.")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)

                NavigationLink {
                    RemindersView(reminderService: reminderService)
                } label: {
                    SectionCard(title: "Reminders", systemImage: "bell") {
                        Text(reminderService.isEnabled ? "Daily reminder is on." : "Set a daily capture reminder.")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                            .multilineTextAlignment(.leading)
                    }
                }
                .buttonStyle(.plain)

                SectionCard(title: "About", systemImage: "info.circle") {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("FrameOnce")
                            .font(AppTheme.title(18))
                            .foregroundStyle(AppTheme.parchment)
                        Text("One frame. One meaning. A quiet offline journal.")
                            .font(AppTheme.chromeFont(14))
                            .foregroundStyle(AppTheme.mist)
                    }
                }
            }
            .padding(20)
        }
        .background { AppBackground() }
        .navigationTitle("More")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
