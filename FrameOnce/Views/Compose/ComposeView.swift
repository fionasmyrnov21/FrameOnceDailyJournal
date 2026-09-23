import SwiftUI

struct ComposeView: View {
    @StateObject var viewModel: ComposeViewModel
    var onRetake: () -> Void
    var onSaved: () -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                DuoAdaptiveArrangement {
                    FilmCardChrome(date: Date(), title: viewModel.title) {
                        AtmosphereStyledImage(
                            image: viewModel.image,
                            atmosphere: viewModel.selectedAtmosphere
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(3 / 4, contentMode: .fit)
                    }
                    .padding(16)
                    .offset(y: viewModel.revealCard ? 0 : 36)
                    .opacity(viewModel.revealCard ? 1 : 0)
                } secondary: {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Title")
                                .font(AppTheme.caption(12, weight: .semibold))
                                .foregroundStyle(AppTheme.mist)
                            TextField("Card title", text: $viewModel.title)
                                .font(AppTheme.title(26).weight(viewModel.selectedAtmosphere.captionWeight))
                                .foregroundStyle(AppTheme.parchment)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(AppTheme.surface)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                                        .stroke(AppTheme.hairline, lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                            Text("Associations")
                                .font(AppTheme.caption(12, weight: .semibold))
                                .foregroundStyle(AppTheme.mist)
                            EditableAssociationFields(associations: $viewModel.associations)

                            Text("Atmosphere")
                                .font(AppTheme.chromeFont(13, weight: .semibold))
                                .foregroundStyle(AppTheme.mist)
                            AtmosphereStrip(
                                atmospheres: viewModel.atmospheres,
                                selectedId: $viewModel.selectedAtmosphereId
                            )

                            if let saveError = viewModel.saveError {
                                Text(saveError)
                                    .font(AppTheme.chromeFont(13))
                                    .foregroundStyle(AppTheme.warmAccent)
                            }

                            if viewModel.didSave, let shareImage = viewModel.shareImage {
                                ShareLink(
                                    item: ShareableCardImage(image: shareImage),
                                    preview: SharePreview(viewModel.title, image: Image(uiImage: shareImage))
                                ) {
                                    Label("Share Card", systemImage: "square.and.arrow.up")
                                        .font(AppTheme.chromeFont(15, weight: .semibold))
                                        .foregroundStyle(AppTheme.graphite)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(AppTheme.parchment)
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Compose")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Retake") { onRetake() }
                        .disabled(viewModel.didSave)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.didSave ? "Done" : "Save") {
                        if viewModel.didSave {
                            onSaved()
                        } else {
                            _ = viewModel.save()
                        }
                    }
                    .disabled(viewModel.isSaving)
                    .fontWeight(.semibold)
                }
            }
            .toolbarBackground(AppTheme.surface, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .onAppear { viewModel.onAppear() }
        }
    }
}
