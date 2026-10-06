import Combine
import Foundation
import UIKit

struct WeekDayStrip: Identifiable {
    let id: Date
    let dayLabel: String
    let cards: [FrameCard]
}

final class WeekGlanceViewModel: ObservableObject {
    @Published private(set) var strips: [WeekDayStrip] = []
    @Published private(set) var totalCount: Int = 0
    @Published var selectedCardID: UUID?

    private let store: FrameCardStore
    private var cancellables = Set<AnyCancellable>()

    init(store: FrameCardStore) {
        self.store = store
        store.$cards
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.rebuild()
            }
            .store(in: &cancellables)
        rebuild()
    }

    func image(for card: FrameCard) -> UIImage? {
        store.image(for: card)
    }

    func card(with id: UUID?) -> FrameCard? {
        guard let id else { return nil }
        return store.cards.first(where: { $0.id == id })
    }

    private func rebuild() {
        let calendar = Calendar.current
        let now = Date()
        guard let week = calendar.dateInterval(of: .weekOfYear, for: now) else {
            strips = []
            totalCount = 0
            return
        }

        let weekCards = store.cards.filter { week.contains($0.createdAt) }
        totalCount = weekCards.count

        var days: [WeekDayStrip] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: week.start) else { continue }
            let dayCards = weekCards
                .filter { calendar.isDate($0.createdAt, inSameDayAs: day) }
                .sorted { $0.createdAt > $1.createdAt }
            days.append(
                WeekDayStrip(
                    id: day,
                    dayLabel: formatter.string(from: day),
                    cards: dayCards
                )
            )
        }
        strips = days
    }
}
