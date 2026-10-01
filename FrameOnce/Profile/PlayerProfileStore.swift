import Combine
import Foundation
import UIKit

final class PlayerProfileStore: ObservableObject {
    static let shared = PlayerProfileStore()

    @Published private(set) var displayName: String
    @Published private(set) var avatarImage: UIImage?

    private let nameKey = "frameonce_profile_display_name"
    private let fileManager = FileManager.default
    private let avatarFileURL: URL

    private init() {
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? fileManager.temporaryDirectory
        let directory = support.appendingPathComponent("PlayerProfile", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        avatarFileURL = directory.appendingPathComponent("avatar.jpg")
        displayName = UserDefaults.standard.string(forKey: nameKey) ?? "Frame Keeper"
        loadAvatar()
    }

    func updateDisplayName(_ name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        displayName = trimmed.isEmpty ? "Frame Keeper" : trimmed
        UserDefaults.standard.set(displayName, forKey: nameKey)
    }

    func saveAvatar(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.88) else { return }
        try? data.write(to: avatarFileURL, options: .atomic)
        avatarImage = image
    }

    func clearAvatar() {
        try? fileManager.removeItem(at: avatarFileURL)
        avatarImage = nil
    }

    private func loadAvatar() {
        guard let data = try? Data(contentsOf: avatarFileURL),
              let image = UIImage(data: data) else {
            avatarImage = nil
            return
        }
        avatarImage = image
    }
}
