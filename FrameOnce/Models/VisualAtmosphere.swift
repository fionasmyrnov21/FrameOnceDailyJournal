import SwiftUI

struct VisualAtmosphere: Identifiable, Equatable, Hashable {
    let id: String
    let name: String
    let overlayColor: Color
    let overlayOpacity: Double
    let contrastBoost: Double
    let grainOpacity: Double
    let frameTone: Color
    let captionWeight: Font.Weight

    static let all: [VisualAtmosphere] = [
        VisualAtmosphere(
            id: "soft_dawn",
            name: "Soft Dawn",
            overlayColor: Color(red: 0.96, green: 0.78, blue: 0.55),
            overlayOpacity: 0.22,
            contrastBoost: 0.05,
            grainOpacity: 0.08,
            frameTone: Color(red: 0.92, green: 0.86, blue: 0.76),
            captionWeight: .regular
        ),
        VisualAtmosphere(
            id: "quiet_ink",
            name: "Quiet Ink",
            overlayColor: Color(red: 0.18, green: 0.22, blue: 0.28),
            overlayOpacity: 0.28,
            contrastBoost: 0.12,
            grainOpacity: 0.14,
            frameTone: Color(red: 0.72, green: 0.76, blue: 0.80),
            captionWeight: .medium
        ),
        VisualAtmosphere(
            id: "warm_ember",
            name: "Warm Ember",
            overlayColor: Color(red: 0.78, green: 0.38, blue: 0.22),
            overlayOpacity: 0.24,
            contrastBoost: 0.10,
            grainOpacity: 0.10,
            frameTone: Color(red: 0.95, green: 0.72, blue: 0.48),
            captionWeight: .semibold
        ),
        VisualAtmosphere(
            id: "cool_mist",
            name: "Cool Mist",
            overlayColor: Color(red: 0.45, green: 0.62, blue: 0.70),
            overlayOpacity: 0.26,
            contrastBoost: 0.06,
            grainOpacity: 0.12,
            frameTone: Color(red: 0.78, green: 0.88, blue: 0.92),
            captionWeight: .regular
        ),
        VisualAtmosphere(
            id: "paper_grain",
            name: "Paper Grain",
            overlayColor: Color(red: 0.86, green: 0.82, blue: 0.74),
            overlayOpacity: 0.30,
            contrastBoost: 0.08,
            grainOpacity: 0.22,
            frameTone: Color(red: 0.94, green: 0.91, blue: 0.85),
            captionWeight: .medium
        ),
        VisualAtmosphere(
            id: "night_film",
            name: "Night Film",
            overlayColor: Color(red: 0.08, green: 0.10, blue: 0.16),
            overlayOpacity: 0.34,
            contrastBoost: 0.18,
            grainOpacity: 0.20,
            frameTone: Color(red: 0.55, green: 0.58, blue: 0.66),
            captionWeight: .semibold
        )
    ]

    static func atmosphere(for id: String) -> VisualAtmosphere {
        all.first(where: { $0.id == id }) ?? all[0]
    }
}
