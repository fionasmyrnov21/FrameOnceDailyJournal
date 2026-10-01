import Combine
import Foundation
import UIKit

final class JournalViewModel: ObservableObject {
    @Published var filter: JournalFilter = .today
    @Published var searchText: String = ""
    @Published var selectedCardID: UUID?

    private let store: FrameCardStore
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var cards: [FrameCard] = []

    init(store: FrameCardStore) {
        self.store = store
        store.$cards
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
        $filter
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
        $searchText
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.refresh()
            }
            .store(in: &cancellables)
        refresh()
    }

    func refresh() {
        cards = store.cardsMatching(search: searchText, filter: filter)
    }

    func image(for card: FrameCard) -> UIImage? {
        store.image(for: card)
    }

    func card(with id: UUID?) -> FrameCard? {
        guard let id else { return nil }
        return store.cards.first(where: { $0.id == id })
    }
}
