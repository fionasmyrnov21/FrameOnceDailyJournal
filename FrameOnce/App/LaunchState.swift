import Foundation
import Combine

final class LaunchState: ObservableObject {
    static let shared = LaunchState()

    static let didChangeNotification = NSNotification.Name("LaunchStateDidChange")

    @Published var portalDestination: String? {
        didSet {
            guard portalDestination != oldValue else { return }
            notifyChange()
        }
    }
    @Published var isPrePermissionVisible: Bool = false {
        didSet {
            guard isPrePermissionVisible != oldValue else { return }
            notifyChange()
        }
    }
    @Published var noInternetMessage: String? {
        didSet {
            guard noInternetMessage != oldValue else { return }
            notifyChange()
        }
    }

    private func notifyChange() {
        if Thread.isMainThread {
            NotificationCenter.default.post(name: LaunchState.didChangeNotification, object: nil)
        } else {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: LaunchState.didChangeNotification, object: nil)
            }
        }
    }

    private let destinationKey = "saved_portal_destination"
    private let expiresKey = "saved_portal_destination_expires"
    private let payloadKey = "saved_config_payload"
    private let permanentNativeKey = "permanent_native_flow"
    private let pushDestinationKey = "saved_push_destination"
    private let lastOpenedDestinationKey = "last_opened_destination"
    private let installMarkerKey = "app_install_initialized"
    private let firstServerDecisionRecordedKey = "first_server_decision_recorded"
    private let firstServerDecisionHasLinkKey = "first_server_decision_has_link"

    private(set) var pendingDestination: String?
    private(set) var didOpenPushDestination = false
    private var shouldForcePortalReload = false
    private var pendingForceReloadDestination: String?

    private init() {}

    func resetPersistentStateOnFreshInstallIfNeeded() {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: installMarkerKey) else { return }

        defaults.set(true, forKey: installMarkerKey)

        defaults.removeObject(forKey: destinationKey)
        defaults.removeObject(forKey: expiresKey)
        defaults.removeObject(forKey: payloadKey)
        defaults.removeObject(forKey: permanentNativeKey)
        defaults.removeObject(forKey: pushDestinationKey)
        defaults.removeObject(forKey: lastOpenedDestinationKey)
        defaults.removeObject(forKey: firstServerDecisionRecordedKey)
        defaults.removeObject(forKey: firstServerDecisionHasLinkKey)
        defaults.removeObject(forKey: "push_permission_last_decline")
        defaults.removeObject(forKey: "stored_fcm_token")
        defaults.removeObject(forKey: "last_sent_push_token_in_config")
        defaults.removeObject(forKey: "push_permission_granted")

        pendingDestination = nil
        portalDestination = nil
        isPrePermissionVisible = false
        noInternetMessage = nil
        didOpenPushDestination = false
        shouldForcePortalReload = false
        pendingForceReloadDestination = nil
    }

    func markDidOpenPushDestination() {
        didOpenPushDestination = true
    }

    func requestForcePortalReload(for destination: String? = nil) {
        shouldForcePortalReload = true
        pendingForceReloadDestination = destination
    }

    func consumeForcePortalReload(for destination: String? = nil) -> Bool {
        guard shouldForcePortalReload else { return false }
        if let pending = pendingForceReloadDestination {
            guard let destination, destination == pending else { return false }
        }
        shouldForcePortalReload = false
        pendingForceReloadDestination = nil
        return true
    }

    func activatePushSlotIfNeeded() -> Bool {
        guard !isPermanentNativeFlow() else { return false }
        guard let pushAddress = consumePushDestination() else { return false }
        markDidOpenPushDestination()
        requestForcePortalReload(for: pushAddress)
        portalDestination = pushAddress
        return true
    }

    func activateStoredDestinationIfValid() -> Bool {
        if isPermanentNativeFlow() {
            clearStoredDestination()
            clearLastOpenedDestination()
            portalDestination = nil
            return false
        }

        if activatePushSlotIfNeeded() {
            return true
        }

        if let stored = storedEndpointDestination(), !stored.isEmpty {
            saveLastOpenedDestination(stored)
            portalDestination = stored
            return true
        }

        if let lastOpened = lastOpenedDestination(), !lastOpened.isEmpty {
            portalDestination = lastOpened
            return true
        }

        portalDestination = nil
        return false
    }

    func storedEndpointDestination() -> String? {
        guard !isPermanentNativeFlow() else { return nil }
        guard let destination = UserDefaults.standard.string(forKey: destinationKey),
              !destination.isEmpty else {
            return nil
        }
        return destination
    }

    func isStoredDestinationExpired(now: TimeInterval = Date().timeIntervalSince1970) -> Bool {
        guard UserDefaults.standard.string(forKey: destinationKey) != nil else { return true }
        return UserDefaults.standard.double(forKey: expiresKey) <= now
    }

    func hasUnexpiredStoredDestination() -> Bool {
        guard storedEndpointDestination() != nil else { return false }
        return !isStoredDestinationExpired()
    }

    func saveDestination(_ destination: String, expires: TimeInterval) {
        guard !isPermanentNativeFlow() else { return }
        if didOpenPushDestination {
            persistDestinationWithoutOpening(destination, expires: expires)
            return
        }
        UserDefaults.standard.set(destination, forKey: destinationKey)
        UserDefaults.standard.set(expires, forKey: expiresKey)
        saveLastOpenedDestination(destination)
        prepareToOpenPortal(destination)
    }

    func persistDestinationWithoutOpening(_ destination: String, expires: TimeInterval) {
        guard !isPermanentNativeFlow() else { return }
        UserDefaults.standard.set(destination, forKey: destinationKey)
        UserDefaults.standard.set(expires, forKey: expiresKey)
    }

    func hasStoredDestination() -> Bool {
        storedEndpointDestination() != nil
    }

    func hasOpenableDestination() -> Bool {
        guard !isPermanentNativeFlow() else { return false }
        if hasStoredDestination() { return true }
        if let lastOpened = lastOpenedDestination(), !lastOpened.isEmpty {
            return true
        }
        return false
    }

    func lastOpenedDestination() -> String? {
        UserDefaults.standard.string(forKey: lastOpenedDestinationKey)
    }

    func saveLastOpenedDestination(_ address: String) {
        UserDefaults.standard.set(address, forKey: lastOpenedDestinationKey)
    }

    func clearLastOpenedDestination() {
        UserDefaults.standard.removeObject(forKey: lastOpenedDestinationKey)
    }

    func clearStoredDestination() {
        UserDefaults.standard.removeObject(forKey: destinationKey)
        UserDefaults.standard.removeObject(forKey: expiresKey)
    }

    func saveConfigPayload(_ payload: [String: Any]) {
        guard JSONSerialization.isValidJSONObject(payload),
              let data = try? JSONSerialization.data(withJSONObject: payload) else { return }
        UserDefaults.standard.set(data, forKey: payloadKey)
    }

    func storedConfigPayload() -> [String: Any]? {
        guard let data = UserDefaults.standard.data(forKey: payloadKey),
              let json = try? JSONSerialization.jsonObject(with: data),
              let payload = json as? [String: Any] else { return nil }
        return payload
    }

    func isPermanentNativeFlow() -> Bool {
        let saved = UserDefaults.standard.string(forKey: destinationKey) ?? ""
        return saved.isEmpty && UserDefaults.standard.bool(forKey: permanentNativeKey)
    }

    func lockPermanentNativeFlow() {
        guard !hasStoredDestination() else { return }
        UserDefaults.standard.set(true, forKey: permanentNativeKey)
        clearStoredDestination()
        clearLastOpenedDestination()
        portalDestination = nil
    }

    func recordFirstServerDecision(hasValidLink: Bool) {
        let defaults = UserDefaults.standard
        guard !defaults.bool(forKey: firstServerDecisionRecordedKey) else { return }

        defaults.set(true, forKey: firstServerDecisionRecordedKey)
        defaults.set(hasValidLink, forKey: firstServerDecisionHasLinkKey)

        if !hasValidLink {
            lockPermanentNativeFlow()
        }
    }

    func showNoInternetMessage() {
        if portalDestination != nil { return }
        if openStoredConfigDestination() { return }
        noInternetMessage = "No internet connection. Please turn on the internet and open the app again."
    }

    func savePushDestination(_ address: String) {
        UserDefaults.standard.set(address, forKey: pushDestinationKey)
    }

    func openStoredConfigDestination() -> Bool {
        guard !isPermanentNativeFlow() else { return false }
        guard let stored = storedEndpointDestination(), !stored.isEmpty else { return false }

        UserDefaults.standard.removeObject(forKey: pushDestinationKey)
        didOpenPushDestination = false
        noInternetMessage = nil
        pendingDestination = nil
        requestForcePortalReload(for: stored)
        if portalDestination == stored {
            notifyChange()
        } else {
            portalDestination = stored
        }
        return true
    }

    func consumePushDestination() -> String? {
        let address = UserDefaults.standard.string(forKey: pushDestinationKey)
        UserDefaults.standard.removeObject(forKey: pushDestinationKey)
        return address
    }

    func handleIncomingPushAddress(_ address: String) {
        guard !isPermanentNativeFlow() else { return }

        markDidOpenPushDestination()
        requestForcePortalReload(for: address)
        UserDefaults.standard.removeObject(forKey: pushDestinationKey)
        noInternetMessage = nil
        pendingDestination = nil

        if isPrePermissionVisible {
            isPrePermissionVisible = false
        }

        if portalDestination == address {
            notifyChange()
        } else {
            portalDestination = address
        }
    }

    func prepareToOpenPortal(_ destination: String) {
        NotificationHandler.shared.shouldShowPrePermission { [weak self] shouldShow in
            guard let self = self else { return }
            if shouldShow {
                self.pendingDestination = destination
                self.portalDestination = nil
                self.isPrePermissionVisible = true
            } else {
                self.pendingDestination = nil
                if self.isPrePermissionVisible {
                    self.isPrePermissionVisible = false
                }
                self.portalDestination = destination
            }
        }
    }

    func confirmPrePermissionAndOpen() {
        let target = pendingDestination
        pendingDestination = nil
        isPrePermissionVisible = false
        if let target = target {
            portalDestination = target
        }
    }
}
