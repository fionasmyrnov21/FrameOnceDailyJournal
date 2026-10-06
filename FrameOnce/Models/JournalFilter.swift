import Foundation

enum JournalFilter: String, CaseIterable, Identifiable {
    case today
    case thisWeek
    case favorites
    case all

    var id: String { rawValue }

    var title: String {
        switch self {
        case .today: return "Today"
        case .thisWeek: return "Week"
        case .favorites: return "Favorites"
        case .all: return "All"
        }
    }
}
