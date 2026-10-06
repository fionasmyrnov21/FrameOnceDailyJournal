import SwiftUI

struct AtmosphereStudioView: View {
    @StateObject var viewModel: AtmosphereViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Live Preview")
                    .font(AppTheme.chromeFont(13, weight: .semibold))
                    .foregroundStyle(AppTheme.mist)

                FilmCardChrome(
                    date: viewModel.previewCard?.createdAt ?? Date(),
                    title: viewModel.previewCard?.title ?? "Sample Frame"
                ) {
                    AtmosphereStyledImage(
                        image: viewModel.previewImage,
                        atmosphere: VisualAtmosphere.atmosphere(for: viewModel.selectedId)
                    )
                    .frame(maxWidth: .infinity)
                    .aspectRatio(4 / 3, contentMode: .fit)
                }

                if viewModel.previewCard == nil {
                    Text("Capture a frame to preview styles on a real image.")
                        .font(AppTheme.chromeFont(14))
                        .foregroundStyle(AppTheme.mist)
                }

                Text("Library")
                    .font(AppTheme.chromeFont(13, weight: .semibold))
                    .foregroundStyle(AppTheme.mist)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ],
                    spacing: 12
                ) {
                    ForEach(viewModel.atmospheres) { atmosphere in
                        Button {
                            viewModel.select(atmosphere)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                ZStack(alignment: .topTrailing) {
                                    AtmosphereStyledImage(
                                        image: viewModel.previewImage,
                                        atmosphere: atmosphere
                                    )
                                    .frame(height: 88)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                                    if viewModel.selectedId == atmosphere.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(AppTheme.warmAccent)
                                            .padding(6)
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(
                                            viewModel.selectedId == atmosphere.id
                                                ? AppTheme.warmAccent
                                                : atmosphere.frameTone.opacity(0.4),
                                            lineWidth: viewModel.selectedId == atmosphere.id ? 2 : 1
                                        )
                                )
                                Text(atmosphere.name)
                                    .font(AppTheme.title(16))
                                    .foregroundStyle(AppTheme.parchment)
                                Text("Grain \(Int(atmosphere.grainOpacity * 100)) · Tone")
                                    .font(AppTheme.chromeFont(12))
                                    .foregroundStyle(AppTheme.mist)
                                if viewModel.selectedId == atmosphere.id {
                                    Text("Preferred")
                                        .font(AppTheme.caption(11, weight: .semibold))
                                        .foregroundStyle(AppTheme.warmAccent)
                                }
                            }
                            .padding(10)
                            .background(AppTheme.surfaceElevated)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(AppTheme.hairline, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .background { AppBackground() }
        .navigationTitle("Atmosphere Studio")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}
