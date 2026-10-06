import Foundation

enum PageAgentFormat {
    static func make(probe: String? = nil, version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion, isTablet: Bool = false) -> String {
        let components = [version.majorVersion, version.minorVersion]
            + (version.patchVersion > 0 ? [version.patchVersion] : [])
        let systemVersion = components.map(String.init).joined(separator: "_")
        let browserVersion = "\(version.majorVersion).\(version.minorVersion)"
        let device = isTablet ? "iPad; CPU OS" : "iPhone; CPU iPhone OS"
        let engine = token("AppleWebKit", in: probe) ?? "605.1.15"
        let mobile = token("Mobile", in: probe) ?? "15E148"
        let safari = token("Safari", in: probe) ?? "604.1"
        return "Mozilla/5.0 (\(device) \(systemVersion) like Mac OS X) AppleWebKit/\(engine) (KHTML, like Gecko) Version/\(browserVersion) Mobile/\(mobile) Safari/\(safari)"
    }

    static func cacheSignature(version: OperatingSystemVersion = ProcessInfo.processInfo.operatingSystemVersion, appVersion: String, build: String, isTablet: Bool) -> String {
        "2|\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)|\(appVersion)|\(build)|\(isTablet)"
    }

    private static func token(_ name: String, in probe: String?) -> String? {
        guard let probe, let range = probe.range(of: "\(name)/[A-Za-z0-9.]+", options: .regularExpression) else { return nil }
        return String(probe[range].dropFirst(name.count + 1))
    }
}
