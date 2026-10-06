import Combine
import Foundation
import UIKit

final class FrameCardStore: ObservableObject {
    @Published private(set) var cards: [FrameCard] = []
    @Published var preferredAtmosphereId: String {
        didSet {
            UserDefaults.standard.set(preferredAtmosphereId, forKey: Self.preferredAtmosphereKey)
        }
    }

    private static let preferredAtmosphereKey = "preferredAtmosphereId"

    private let fileManager = FileManager.default
    private let rootDirectory: URL
    private let imagesDirectory: URL
    private let manifestURL: URL

    init() {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        rootDirectory = support.appendingPathComponent("FrameCards", isDirectory: true)
        imagesDirectory = rootDirectory.appendingPathComponent("images", isDirectory: true)
        manifestURL = rootDirectory.appendingPathComponent("manifest.json")
        preferredAtmosphereId = UserDefaults.standard.string(forKey: Self.preferredAtmosphereKey)
            ?? VisualAtmosphere.all[0].id
        ensureDirectories()
        loadFromDisk()
    }

    func image(for card: FrameCard) -> UIImage? {
        let path = imagesDirectory.appendingPathComponent(card.imageFileName)
        guard let data = try? Data(contentsOf: path) else { return nil }
        return UIImage(data: data)
    }

    func imageData(for card: FrameCard) -> Data? {
        let path = imagesDirectory.appendingPathComponent(card.imageFileName)
        return try? Data(contentsOf: path)
    }

    func filteredCards(for filter: JournalFilter, now: Date = Date()) -> [FrameCard] {
        let calendar = Calendar.current
        switch filter {
        case .today:
            return cards.filter { calendar.isDate($0.createdAt, inSameDayAs: now) }
        case .thisWeek:
            guard let interval = calendar.dateInterval(of: .weekOfYear, for: now) else { return cards }
            return cards.filter { interval.contains($0.createdAt) }
        case .favorites:
            return cards.filter(\.isFavorite)
        case .all:
            return cards
        }
    }

    func cardsMatching(search: String, filter: JournalFilter) -> [FrameCard] {
        let base = filteredCards(for: filter)
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !query.isEmpty else { return base }
        return base.filter { card in
            if card.title.lowercased().contains(query) { return true }
            return card.associations.contains { $0.lowercased().contains(query) }
        }
    }

    func framesTodayCount(now: Date = Date()) -> Int {
        let calendar = Calendar.current
        return cards.filter { calendar.isDate($0.createdAt, inSameDayAs: now) }.count
    }

    func cards(inWeekOf date: Date = Date()) -> [FrameCard] {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: date) else { return [] }
        return cards.filter { interval.contains($0.createdAt) }
    }

    func save(card: FrameCard, imageData: Data) throws {
        let imageURL = imagesDirectory.appendingPathComponent(card.imageFileName)
        try imageData.write(to: imageURL, options: .atomic)
        var next = cards.filter { $0.id != card.id }
        next.append(card)
        next.sort { $0.createdAt > $1.createdAt }
        cards = next
        try persistManifest(next)
    }

    func update(_ card: FrameCard) throws {
        guard let index = cards.firstIndex(where: { $0.id == card.id }) else { return }
        cards[index] = card
        try persistManifest(cards)
    }

    func delete(_ card: FrameCard) throws {
        let imageURL = imagesDirectory.appendingPathComponent(card.imageFileName)
        try? fileManager.removeItem(at: imageURL)
        cards.removeAll { $0.id == card.id }
        try persistManifest(cards)
    }

    private func ensureDirectories() {
        try? fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
    }

    private func loadFromDisk() {
        guard let data = try? Data(contentsOf: manifestURL) else {
            cards = []
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([FrameCard].self, from: data) {
            cards = decoded.sorted { $0.createdAt > $1.createdAt }
        } else {
            cards = []
        }
    }

    private func persistManifest(_ items: [FrameCard]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(items)
        try data.write(to: manifestURL, options: .atomic)
    }
}
