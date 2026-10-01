import Foundation
import UIKit
@preconcurrency import Vision

struct SceneInsightEngine {
    func analyze(image: UIImage) async -> SceneInsight {
        guard let cgImage = image.cgImage else {
            return fallbackInsight()
        }

        let labels = await classify(cgImage: cgImage)
        return mapLabels(labels)
    }

    private func classify(cgImage: CGImage) async -> [String] {
        await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNClassifyImageRequest()
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                    let observations = request.results ?? []
                    let top = observations
                        .prefix(5)
                        .filter { $0.confidence > 0.12 }
                        .map { $0.identifier.lowercased() }
                    continuation.resume(returning: Array(top))
                } catch {
                    continuation.resume(returning: [])
                }
            }
        }
    }

    private func mapLabels(_ labels: [String]) -> SceneInsight {
        guard !labels.isEmpty else { return fallbackInsight() }

        let joined = labels.joined(separator: " ")
        for entry in Self.templates {
            if entry.keywords.contains(where: { joined.contains($0) }) {
                return SceneInsight(
                    title: entry.title,
                    associations: Array(entry.associations.prefix(2)),
                    classifierLabels: labels
                )
            }
        }

        let first = labels.first ?? "detail"
        let title = Self.prettyTitle(from: first)
        return SceneInsight(
            title: title,
            associations: [
                "A moment held still",
                "Part of today's frame"
            ],
            classifierLabels: labels
        )
    }

    private func fallbackInsight() -> SceneInsight {
        SceneInsight(
            title: "Quiet Detail",
            associations: [
                "Something small noticed",
                "A pause in the day"
            ],
            classifierLabels: []
        )
    }

    private static func prettyTitle(from label: String) -> String {
        let cleaned = label
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
        return cleaned.capitalized
    }

    private struct Template {
        let keywords: [String]
        let title: String
        let associations: [String]
    }

    private static let templates: [Template] = [
        Template(
            keywords: ["cup", "mug", "coffee", "tea", "drink"],
            title: "Morning Vessel",
            associations: ["Warm pause", "Steam and stillness"]
        ),
        Template(
            keywords: ["book", "notebook", "paper", "magazine"],
            title: "Open Pages",
            associations: ["Quiet reading", "Ink and margin"]
        ),
        Template(
            keywords: ["plant", "flower", "leaf", "tree", "garden"],
            title: "Living Green",
            associations: ["Soft growth", "Outdoor hush"]
        ),
        Template(
            keywords: ["desk", "laptop", "keyboard", "monitor", "office"],
            title: "Work Corner",
            associations: ["Focus hour", "Tools at rest"]
        ),
        Template(
            keywords: ["window", "door", "architecture", "building", "wall"],
            title: "Threshold Light",
            associations: ["Edge of place", "Daylight frame"]
        ),
        Template(
            keywords: ["street", "road", "city", "car", "sidewalk"],
            title: "Passing Place",
            associations: ["Motion paused", "Urban texture"]
        ),
        Template(
            keywords: ["food", "plate", "fruit", "bread", "meal"],
            title: "Table Moment",
            associations: ["Shared quiet", "Daily ritual"]
        ),
        Template(
            keywords: ["shoe", "bag", "jacket", "hat", "cloth"],
            title: "Worn Companion",
            associations: ["Carried story", "Ready to go"]
        ),
        Template(
            keywords: ["sky", "cloud", "sunset", "sunrise", "horizon"],
            title: "Wide Sky",
            associations: ["Open air", "Color shift"]
        ),
        Template(
            keywords: ["chair", "sofa", "bed", "lamp", "interior"],
            title: "Room Stillness",
            associations: ["Home hush", "Familiar shape"]
        ),
        Template(
            keywords: ["water", "river", "sea", "lake", "ocean"],
            title: "Water Edge",
            associations: ["Gentle current", "Reflected light"]
        ),
        Template(
            keywords: ["hand", "person", "face", "portrait", "people"],
            title: "Human Trace",
            associations: ["Presence nearby", "Shared frame"]
        )
    ]
}
