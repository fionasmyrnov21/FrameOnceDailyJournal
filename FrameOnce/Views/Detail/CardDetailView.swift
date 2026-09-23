import SwiftUI

struct CardDetailView: View {
    @StateObject var viewModel: CardDetailViewModel
    var onDeleted: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                FilmCardChrome(date: viewModel.card.createdAt, title: nil) {
                    AtmosphereStyledImage(
                        image: viewModel.image,
                        atmosphere: viewModel.atmosphere
                    )
                    .frame(maxWidth: .infinity)
                    .aspectRatio(3 / 4, contentMode: .fit)
                }

                VStack(alignment: .leading, spacing: 14) {
                    Text("Title")
                        .font(AppTheme.caption(12, weight: .semibold))
                        .foregroundStyle(AppTheme.mist)
                    TextField("Card title", text: Binding(
                        get: { viewModel.card.title },
                        set: { viewModel.updateTitle($0) }
                    ))
                    .font(AppTheme.display(28).weight(viewModel.atmosphere.captionWeight))
                    .foregroundStyle(AppTheme.parchment)

                    Text("Associations")
                        .font(AppTheme.caption(12, weight: .semibold))
                        .foregroundStyle(AppTheme.mist)
                    EditableAssociationFields(associations: $viewModel.draftAssociations)
                        .onChange(of: viewModel.draftAssociations) { _ in
                            viewModel.commitAssociations()
                        }

                    HStack {
                        Text(viewModel.card.createdAt.formatted(date: .abbreviated, time: .shortened))
                            .font(AppTheme.chromeFont(13))
                            .foregroundStyle(AppTheme.mist)
                        Spacer()
                        Text("Atmosphere · \(viewModel.atmosphere.name)")
                            .font(AppTheme.chromeFont(14, weight: .medium))
                            .foregroundStyle(AppTheme.warmAccent)
                    }

                    if let shareImage = viewModel.shareImage {
                        ShareLink(
                            item: ShareableCardImage(image: shareImage),
                            preview: SharePreview(viewModel.card.title, image: Image(uiImage: shareImage))
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
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surfaceElevated)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(20)
        }
        .background { AppBackground() }
        .navigationTitle("Card")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                HStack(spacing: 12) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Label(
                            "Favorite",
                            systemImage: viewModel.card.isFavorite ? "heart.fill" : "heart"
                        )
                    }
                    Button {
                        viewModel.showAtmospherePicker = true
                    } label: {
                        Label("Atmosphere", systemImage: "paintpalette")
                    }
                }
            }
            ToolbarItem(placement: .destructiveAction) {
                Button(role: .destructive) {
                    viewModel.confirmDelete = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $viewModel.showAtmospherePicker) {
            AtmospherePickerSheet(
                selectedId: viewModel.card.atmosphereId,
                onSelect: { atmosphere in
                    viewModel.applyAtmosphere(atmosphere)
                    viewModel.showAtmospherePicker = false
                }
            )
            .presentationDetents([.medium, .large])
        }
        .alert("Delete this card?", isPresented: $viewModel.confirmDelete) {
            Button("Delete", role: .destructive) {
                viewModel.delete()
                onDeleted()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This frame will be removed from your journal.")
        }
    }
}

struct AtmospherePickerSheet: View {
    let selectedId: String
    let onSelect: (VisualAtmosphere) -> Void

    var body: some View {
        NavigationStack {
            List(VisualAtmosphere.all) { atmosphere in
                Button {
                    onSelect(atmosphere)
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(atmosphere.overlayColor)
                            .frame(width: 24, height: 24)
                        Text(atmosphere.name)
                            .foregroundStyle(AppTheme.parchment)
                        Spacer()
                        if atmosphere.id == selectedId {
                            Image(systemName: "checkmark")
                                .foregroundStyle(AppTheme.warmAccent)
                        }
                    }
                }
                .listRowBackground(AppTheme.surfaceElevated)
            }
            .scrollContentBackground(.hidden)
            .background { AppBackground() }
            .navigationTitle("Atmosphere")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(AppTheme.surface, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}
