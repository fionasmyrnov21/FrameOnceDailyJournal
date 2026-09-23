import Foundation

struct FrameLevel: Identifiable, Equatable {
    let id: Int
    let title: String
    let detail: String
    let goalLabel: String
    let requiredValue: Int

    static let all: [FrameLevel] = [
        FrameLevel(
            id: 0,
            title: "First Frame",
            detail: "Begin your quiet journal.",
            goalLabel: "Always open",
            requiredValue: 0
        ),
        FrameLevel(
            id: 1,
            title: "Daily Habit",
            detail: "Save three cards to build a rhythm.",
            goalLabel: "3 saved cards",
            requiredValue: 3
        ),
        FrameLevel(
            id: 2,
            title: "Week Keeper",
            detail: "Capture on three different days.",
            goalLabel: "3 distinct days",
            requiredValue: 3
        ),
        FrameLevel(
            id: 3,
            title: "Curator",
            detail: "Mark two favorites worth keeping.",
            goalLabel: "2 favorites",
            requiredValue: 2
        ),
        FrameLevel(
            id: 4,
            title: "Atmosphere Adept",
            detail: "Apply three different atmospheres.",
            goalLabel: "3 atmospheres",
            requiredValue: 3
        )
    ]
}
