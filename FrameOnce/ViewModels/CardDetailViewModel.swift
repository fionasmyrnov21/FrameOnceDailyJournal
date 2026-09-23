import Combine
import Foundation
import UIKit

@MainActor
final class CardDetailViewModel: ObservableObject {
    @Published var card: FrameCard
    @Published var draftAssociations: [String]
    @Published var showAtmospherePicker = false
    @Published var confirmDelete = false
    @Published var shareImage: UIImage?

    private let store: FrameCardStore

    init(card: FrameCard, store: FrameCardStore) {
        self.card = card
        self.store = store
        var associations = card.associations
        while associations.count < 2 {
            associations.append("")
        }
        self.draftAssociations = Array(associations.prefix(2))
        refreshShareImage()
    }

    var image: UIImage? {
        store.image(for: card)
    }

    var atmosphere: VisualAtmosphere {
        VisualAtmosphere.atmosphere(for: card.atmosphereId)
    }

    func updateTitle(_ title: String) {
        card.title = title
        persist()
    }

    func commitAssociations() {
        card.associations = draftAssociations
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(2)
            .map { $0 }
        persist()
    }

    func toggleFavorite() {
        card.isFavorite.toggle()
        persist()
        if card.isFavorite {
            HapticFeedback.success()
        } else {
            HapticFeedback.light()
        }
    }

    func applyAtmosphere(_ atmosphere: VisualAtmosphere) {
        card.atmosphereId = atmosphere.id
        persist()
    }

    func delete() {
        try? store.delete(card)
    }

    private func persist() {
        try? store.update(card)
        refreshShareImage()
    }

    private func refreshShareImage() {
        shareImage = CardShareRenderer.render(
            image: image,
            title: card.title,
            associations: card.associations,
            atmosphere: atmosphere,
            date: card.createdAt
        )
    }
}
