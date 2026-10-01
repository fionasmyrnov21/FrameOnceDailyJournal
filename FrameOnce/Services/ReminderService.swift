import Combine
import Foundation
import UserNotifications
import UIKit

final class ReminderService: ObservableObject {
    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Self.enabledKey)
            if !isEnabled {
                cancelReminder()
            }
        }
    }

    @Published var reminderTime: Date {
        didSet {
            UserDefaults.standard.set(reminderTime.timeIntervalSinceReferenceDate, forKey: Self.timeKey)
            if isEnabled {
                Task { await scheduleIfAuthorized() }
            }
        }
    }

    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private static let enabledKey = "reminderEnabled"
    private static let timeKey = "reminderTimeInterval"
    private static let askedAfterSaveKey = "reminderAskedAfterSave"
    private static let notificationId = "frameonce.daily.reminder"

    init() {
        isEnabled = UserDefaults.standard.bool(forKey: Self.enabledKey)
        if UserDefaults.standard.object(forKey: Self.timeKey) != nil {
            let interval = UserDefaults.standard.double(forKey: Self.timeKey)
            reminderTime = Date(timeIntervalSinceReferenceDate: interval)
        } else {
            var components = DateComponents()
            components.hour = 19
            components.minute = 0
            reminderTime = Calendar.current.date(from: components) ?? Date()
        }
        refreshAuthorizationStatus()
        if isEnabled {
            Task { await scheduleIfAuthorized() }
        }
    }

    var hasAskedAfterSave: Bool {
        UserDefaults.standard.bool(forKey: Self.askedAfterSaveKey)
    }

    func markAskedAfterSave() {
        UserDefaults.standard.set(true, forKey: Self.askedAfterSaveKey)
    }

    func refreshAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            let status = settings.authorizationStatus
            Task { @MainActor in
                self.authorizationStatus = status
            }
        }
    }

    @MainActor
    func setEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await requestAuthorization()
            refreshAuthorizationStatus()
            if granted {
                isEnabled = true
                await scheduleIfAuthorized()
            } else {
                isEnabled = false
            }
        } else {
            isEnabled = false
            cancelReminder()
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    @MainActor
    func scheduleIfAuthorized() async {
        refreshAuthorizationStatus()
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }
        guard isEnabled else { return }

        cancelReminder()

        let content = UNMutableNotificationContent()
        content.title = "FrameOnce"
        content.body = "One frame is waiting. Capture today's card."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: Self.notificationId,
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [Self.notificationId])
    }

    func openSystemSettings() {
        guard let destination = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(destination)
    }

    var statusLabel: String {
        switch authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "Authorized"
        case .denied:
            return "Denied"
        case .notDetermined:
            return "Not Asked"
        @unknown default:
            return "Unknown"
        }
    }
}
