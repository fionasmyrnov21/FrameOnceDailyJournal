import SwiftUI

struct LevelsView: View {
    @ObservedObject var store: FrameCardStore
    @ObservedObject private var levels = LevelProgressStore.shared

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(FrameLevel.all) { level in
                    levelRow(level)
                }
            }
            .padding(20)
        }
        .background { AppBackground() }
        .navigationTitle("Levels")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            levels.evaluate(using: store.cards)
        }
        .onChange(of: store.cards) { _ in
            levels.evaluate(using: store.cards)
        }
    }

    @ViewBuilder
    private func levelRow(_ level: FrameLevel) -> some View {
        let unlocked = levels.isUnlocked(level.id)
        let current = levels.progress(for: level.id)
        let goal = max(level.requiredValue, 1)
        let fraction = level.requiredValue == 0 ? 1.0 : min(Double(current) / Double(goal), 1.0)

        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(level.title)
                    .font(AppTheme.title(18))
                    .foregroundStyle(unlocked ? AppTheme.parchment : AppTheme.mist.opacity(0.55))
                Spacer()
                Image(systemName: unlocked ? "checkmark.circle.fill" : "lock.fill")
                    .foregroundStyle(unlocked ? AppTheme.warmAccent : AppTheme.mist.opacity(0.45))
            }
            Text(level.detail)
                .font(AppTheme.chromeFont(14))
                .foregroundStyle(AppTheme.mist.opacity(unlocked ? 1 : 0.55))
            Text(level.goalLabel)
                .font(AppTheme.caption(12, weight: .medium))
                .foregroundStyle(AppTheme.mist.opacity(0.8))
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppTheme.surfaceElevated)
                    Capsule()
                        .fill(AppTheme.warmAccent.opacity(unlocked ? 0.9 : 0.35))
                        .frame(width: max(8, geo.size.width * fraction))
                }
            }
            .frame(height: 8)
            if level.requiredValue > 0 {
                Text("\(min(current, level.requiredValue)) / \(level.requiredValue)")
                    .font(AppTheme.caption(12))
                    .foregroundStyle(AppTheme.mist)
            }
        }
        .padding(16)
        .background(AppTheme.surface.opacity(unlocked ? 1 : 0.7))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .opacity(unlocked ? 1 : 0.72)
    }
}
