import Foundation
import UIKit

struct CardComposer {
    func compose(
        insight: SceneInsight,
        atmosphere: VisualAtmosphere,
        imageData: Data,
        createdAt: Date = Date()
    ) -> (card: FrameCard, imageData: Data) {
        let card = FrameCard(
            createdAt: createdAt,
            title: insight.title,
            associations: Array(insight.associations.prefix(2)),
            atmosphereId: atmosphere.id,
            imageFileName: "\(UUID().uuidString).jpg"
        )
        return (card, imageData)
    }

    func jpegData(from image: UIImage, quality: CGFloat = 0.88) -> Data? {
        image.jpegData(compressionQuality: quality)
    }
}
