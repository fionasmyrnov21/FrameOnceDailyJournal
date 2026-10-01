import SwiftUI
import UIKit
import UniformTypeIdentifiers

struct ShareableCardImage: Transferable {
    let image: UIImage

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .jpeg) { item in
            item.image.jpegData(compressionQuality: 0.92) ?? Data()
        }
    }
}

enum CardShareRenderer {
    @MainActor
    static func render(
        image: UIImage?,
        title: String,
        associations: [String],
        atmosphere: VisualAtmosphere,
        date: Date
    ) -> UIImage? {
        let card = ShareCardCanvas(
            image: image,
            title: title,
            associations: associations,
            atmosphere: atmosphere,
            date: date
        )
        .frame(width: 720, height: 960)

        let renderer = ImageRenderer(content: card)
        renderer.scale = 2
        return renderer.uiImage
    }
}

private struct ShareCardCanvas: View {
    let image: UIImage?
    let title: String
    let associations: [String]
    let atmosphere: VisualAtmosphere
    let date: Date

    var body: some View {
        FilmCardChrome(date: date, title: title) {
            VStack(alignment: .leading, spacing: 14) {
                AtmosphereStyledImage(image: image, atmosphere: atmosphere)
                    .frame(maxWidth: .infinity)
                    .frame(height: 620)
                AssociationChips(associations: associations)
                Text("Atmosphere · \(atmosphere.name)")
                    .font(AppTheme.caption(14, weight: .medium))
                    .foregroundStyle(AppTheme.warmAccent)
            }
        }
        .padding(24)
        .background(AppTheme.graphite)
    }
}
