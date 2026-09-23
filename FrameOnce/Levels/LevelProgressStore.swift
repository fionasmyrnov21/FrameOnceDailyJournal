import Combine
import Foundation

final class LevelProgressStore: ObservableObject {
    static let shared = LevelProgressStore()

    @Published private(set) var unlockedMask: Int = 1
    @Published private(set) var progressValues: [Int] = Array(repeating: 0, count: FrameLevel.all.count)

    private let unlockedKey = "frameonce_unlocked_mask"
    private let peaksKey = "frameonce_level_peaks"

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: unlockedKey) == nil {
            defaults.set(1, forKey: unlockedKey)
        }
        unlockedMask = max(defaults.integer(forKey: unlockedKey), 1)
        if let data = defaults.data(forKey: peaksKey),
           let peaks = try? JSONDecoder().decode([Int].self, from: data),
           peaks.count == FrameLevel.all.count {
            progressValues = peaks
        }
    }

    func isUnlocked(_ index: Int) -> Bool {
        guard index >= 0, index < FrameLevel.all.count else { return false }
        if index == 0 { return true }
        return (unlockedMask & (1 << index)) != 0
    }

    func progress(for index: Int) -> Int {
        guard index >= 0, index < progressValues.count else { return 0 }
        return progressValues[index]
    }

    func evaluate(using cards: [FrameCard]) {
        let calendar = Calendar.current
        var next = Array(repeating: 0, count: FrameLevel.all.count)
        next[0] = 1
        next[1] = cards.count
        next[2] = Set(cards.map { calendar.startOfDay(for: $0.createdAt) }).count
        next[3] = cards.filter(\.isFavorite).count
        next[4] = Set(cards.map(\.atmosphereId)).count

        var mask = 1
        for index in 1..<FrameLevel.all.count {
            let previous = index - 1
            let previousMet = next[previous] >= FrameLevel.all[previous].requiredValue
            if previousMet {
                mask |= (1 << index)
            } else {
                break
            }
        }

        if next != progressValues || mask != unlockedMask {
            progressValues = next
            unlockedMask = mask
            persist()
        }
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(unlockedMask, forKey: unlockedKey)
        if let data = try? JSONEncoder().encode(progressValues) {
            defaults.set(data, forKey: peaksKey)
        }
    }
}
