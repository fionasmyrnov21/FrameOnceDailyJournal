import SwiftUI

struct WeekGlanceView: View {
    @ObservedObject var viewModel: WeekGlanceViewModel
    let store: FrameCardStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .firstTextBaseline) {
                    Text("This Week")
                        .font(AppTheme.display(28))
                        .foregroundStyle(AppTheme.parchment)
                    Spacer()
                    Text("\(viewModel.totalCount) frames")
                        .font(AppTheme.chromeFont(15, weight: .semibold))
                        .foregroundStyle(AppTheme.warmAccent)
                }

                ForEach(viewModel.strips) { strip in
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(strip.dayLabel)
                                .font(AppTheme.chromeFont(14, weight: .semibold))
                                .foregroundStyle(AppTheme.mist)
                            Spacer()
                            Text("\(strip.cards.count)")
                                .font(AppTheme.chromeFont(13))
                                .foregroundStyle(AppTheme.parchment.opacity(0.7))
                        }

                        if strip.cards.isEmpty {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(AppTheme.hairline, lineWidth: 1)
                                .frame(height: 72)
                                .background(AppTheme.surface.opacity(0.5))
                                .overlay(
                                    HStack(spacing: 6) {
                                        ForEach(0..<5, id: \.self) { _ in
                                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                                .fill(AppTheme.graphiteSoft)
                                                .frame(width: 28, height: 40)
                                        }
                                    }
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(strip.cards) { card in
                                        NavigationLink {
                                            CardDetailView(
                                                viewModel: CardDetailViewModel(card: card, store: store),
                                                onDeleted: {}
                                            )
                                        } label: {
                                            AtmosphereStyledImage(
                                                image: viewModel.image(for: card),
                                                atmosphere: VisualAtmosphere.atmosphere(for: card.atmosphereId)
                                            )
                                            .frame(width: 78, height: 104)
                                            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                                    .stroke(AppTheme.hairline, lineWidth: 1)
                                            )
                                            .shadow(color: Color.black.opacity(0.28), radius: 6, x: 0, y: 3)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }
                    }
                    .padding(14)
                    .background(AppTheme.surfaceElevated.opacity(0.7))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(AppTheme.hairline, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(20)
        }
        .background { AppBackground() }
        .navigationTitle("Week Glance")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
