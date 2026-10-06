import UIKit
import WebKit

final class PortalPageAgent {
    static let shared = PortalPageAgent()

    private let storageKey = "portal_device_page_agent"
    private let signatureKey = "portal_device_page_agent_signature"
    private var memoryValue: String?
    private var memorySignature: String?
    private var pendingCompletions: [(String) -> Void] = []
    private var resolutionID: UUID?
    private var probe: WKWebView?
    private var deadline: DispatchWorkItem?

    private init() {}

    private var signature: String {
        PageAgentFormat.cacheSignature(
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "",
            build: Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "",
            isTablet: UIDevice.current.userInterfaceIdiom == .pad
        )
    }

    func cachedValue() -> String? {
        let currentSignature = signature
        if memorySignature == currentSignature, let memoryValue {
            return memoryValue
        }
        memoryValue = nil
        memorySignature = nil
        let defaults = UserDefaults.standard
        guard defaults.string(forKey: signatureKey) == currentSignature,
              let stored = defaults.string(forKey: storageKey), !stored.isEmpty else {
            defaults.removeObject(forKey: storageKey)
            defaults.removeObject(forKey: signatureKey)
            return nil
        }
        memoryValue = stored
        memorySignature = currentSignature
        return stored
    }

    func currentValue() -> String {
        cachedValue() ?? PageAgentFormat.make(isTablet: UIDevice.current.userInterfaceIdiom == .pad)
    }

    func prewarm() {
        resolve { _ in }
    }

    func resolve(completion: @escaping (String) -> Void) {
        DispatchQueue.main.async { [self] in
            if let cached = cachedValue() {
                completion(cached)
                return
            }
            pendingCompletions.append(completion)
            guard resolutionID == nil else { return }
            let identifier = UUID()
            resolutionID = identifier
            let configuration = WKWebViewConfiguration()
            configuration.websiteDataStore = .nonPersistent()
            let page = WKWebView(frame: .zero, configuration: configuration)
            probe = page
            let timeout = DispatchWorkItem { [weak self] in
                self?.finishResolve(identifier: identifier, result: nil)
            }
            deadline = timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: timeout)
            page.evaluateJavaScript("navigator.userAgent") { [weak self] result, error in
                DispatchQueue.main.async {
                    self?.finishResolve(identifier: identifier, result: error == nil ? result as? String : nil)
                }
            }
        }
    }

    private func finishResolve(identifier: UUID, result: String?) {
        guard resolutionID == identifier else { return }
        deadline?.cancel()
        deadline = nil
        probe = nil
        resolutionID = nil
        let agent = PageAgentFormat.make(probe: result, isTablet: UIDevice.current.userInterfaceIdiom == .pad)
        let currentSignature = signature
        memoryValue = agent
        memorySignature = currentSignature
        UserDefaults.standard.set(agent, forKey: storageKey)
        UserDefaults.standard.set(currentSignature, forKey: signatureKey)
        let completions = pendingCompletions
        pendingCompletions.removeAll()
        completions.forEach { $0(agent) }
    }
}
