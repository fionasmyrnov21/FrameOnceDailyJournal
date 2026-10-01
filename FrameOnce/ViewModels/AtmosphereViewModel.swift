import Combine
import Foundation
import UIKit

final class AtmosphereViewModel: ObservableObject {
    @Published var selectedId: String

    private let store: FrameCardStore

    var atmospheres: [VisualAtmosphere] { VisualAtmosphere.all }

    init(store: FrameCardStore) {
        self.store = store
        self.selectedId = store.preferredAtmosphereId
    }

    var previewCard: FrameCard? {
        store.cards.first
    }

    var previewImage: UIImage? {
        guard let card = previewCard else { return nil }
        return store.image(for: card)
    }

    var isPreferred: Bool {
        selectedId == store.preferredAtmosphereId
    }

    func select(_ atmosphere: VisualAtmosphere) {
        selectedId = atmosphere.id
        store.preferredAtmosphereId = atmosphere.id
        HapticFeedback.light()
    }
}
