import SwiftUI

struct JournalView: View {
    @ObservedObject var viewModel: JournalViewModel
    let store: FrameCardStore
    var onCaptureCTA: (() -> Void)? = nil
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                NavigationSplitView {
                    journalList
                } detail: {
                    if let card = viewModel.card(with: viewModel.selectedCardID) {
                        CardDetailView(
                            viewModel: CardDetailViewModel(card: card, store: store),
                            onDeleted: { viewModel.selectedCardID = nil }
                        )
                    } else {
                        Text("Select a card")
                            .font(AppTheme.chromeFont(16))
                            .foregroundStyle(AppTheme.mist)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background { AppBackground() }
                    }
                }
            } else {
                NavigationStack {
                    journalList
                        .navigationDestination(for: FrameCard.self) { card in
                            CardDetailView(
                                viewModel: CardDetailViewModel(card: card, store: store),
                                onDeleted: {}
                            )
                        }
                }
            }
        }
    }

    private var journalList: some View {
        VStack(spacing: 0) {
            Picker("Filter", selection: $viewModel.filter) {
                ForEach(JournalFilter.allCases) { filter in
                    Text(filter.title).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if viewModel.cards.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 12),
                            count: DuoGridLayout.columnCount(for: horizontalSizeClass)
                        ),
                        spacing: 12
                    ) {
                        ForEach(Array(viewModel.cards.enumerated()), id: \.element.id) { index, card in
                            journalCell(card)
                                .opacity(1)
                                .transition(.opacity.combined(with: .move(edge: .bottom)))
                                .animation(
                                    .easeOut(duration: 0.35).delay(Double(index) * 0.04),
                                    value: viewModel.cards.map(\.id)
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .background { AppBackground() }
        .navigationTitle("Journal")
        .searchable(text: $viewModel.searchText, prompt: "Search titles and associations")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    @ViewBuilder
    private func journalCell(_ card: FrameCard) -> some View {
        let content = FilmCardChrome(date: card.createdAt, title: nil, showStamp: true) {
            ZStack(alignment: .bottomLeading) {
                AtmosphereStyledImage(
                    image: viewModel.image(for: card),
                    atmosphere: VisualAtmosphere.atmosphere(for: card.atmosphereId)
                )
                .frame(minHeight: 120)
                .aspectRatio(3 / 4, contentMode: .fill)

                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.55)],
                    startPoint: .center,
                    endPoint: .bottom
                )

                HStack(alignment: .bottom) {
                    Text(card.title)
                        .font(AppTheme.title(15))
                        .foregroundStyle(AppTheme.parchment)
                        .lineLimit(2)
                    Spacer(minLength: 4)
                    if card.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(AppTheme.warmAccent)
                    }
                }
                .padding(10)
            }
        }

        if horizontalSizeClass == .regular {
            Button {
                viewModel.selectedCardID = card.id
            } label: {
                content
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink(value: card) {
                content
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
                .frame(width: 72, height: 92)
                .overlay(
                    Image(systemName: "camera")
                        .foregroundStyle(AppTheme.mist)
                )
            Text("No frames yet")
                .font(AppTheme.display(26))
                .foregroundStyle(AppTheme.parchment)
            Text("Capture one frame to begin your film journal.")
                .font(AppTheme.chromeFont(15))
                .foregroundStyle(AppTheme.mist)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            if let onCaptureCTA {
                Button {
                    onCaptureCTA()
                } label: {
                    Text("Capture")
                        .font(AppTheme.chromeFont(16, weight: .semibold))
                        .foregroundStyle(AppTheme.graphite)
                        .padding(.horizontal, 22)
                        .padding(.vertical, 12)
                        .background(AppTheme.warmAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .padding(.top, 4)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
