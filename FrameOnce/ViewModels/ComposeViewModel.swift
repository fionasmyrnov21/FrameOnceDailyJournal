import Combine
import SwiftUI
import UIKit

@MainActor
final class ComposeViewModel: ObservableObject {
    @Published var title: String
    @Published var associations: [String]
    @Published var selectedAtmosphereId: String
    @Published var isSaving = false
    @Published var saveError: String?
    @Published var didSave = false
    @Published var revealCard = false
    @Published var shareImage: UIImage?

    let image: UIImage
    let imageData: Data

    private let store: FrameCardStore
    private let composer = CardComposer()

    var atmospheres: [VisualAtmosphere] { VisualAtmosphere.all }

    var selectedAtmosphere: VisualAtmosphere {
        VisualAtmosphere.atmosphere(for: selectedAtmosphereId)
    }

    init(payload: CaptureViewModel.ComposePayload, store: FrameCardStore) {
        self.image = payload.image
        self.imageData = payload.imageData
        self.title = payload.insight.title
        var associations = Array(payload.insight.associations.prefix(2))
        while associations.count < 2 {
            associations.append("")
        }
        self.associations = associations
        self.selectedAtmosphereId = payload.atmosphereId
        self.store = store
    }

    func onAppear() {
        withAnimation(.spring(response: 0.55, dampingFraction: 0.86)) {
            revealCard = true
        }
    }

    var cleanedAssociations: [String] {
        associations
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(2)
            .map { $0 }
    }

    func save() -> Bool {
        isSaving = true
        defer { isSaving = false }
        let insight = SceneInsight(title: title.trimmingCharacters(in: .whitespacesAndNewlines), associations: cleanedAssociations, classifierLabels: [])
        let composed = composer.compose(
            insight: insight,
            atmosphere: selectedAtmosphere,
            imageData: imageData
        )
        do {
            try store.save(card: composed.card, imageData: composed.imageData)
            shareImage = CardShareRenderer.render(
                image: image,
                title: composed.card.title,
                associations: composed.card.associations,
                atmosphere: selectedAtmosphere,
                date: composed.card.createdAt
            )
            didSave = true
            HapticFeedback.success()
            return true
        } catch {
            saveError = "Could not save this card."
            return false
        }
    }
}
