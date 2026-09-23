import Foundation

enum AppConstants {
    static let appsFlyerDevKey = "TSXkn9yvsRMPCesuwbfCdV"
    static let appsFlyerAppleAppID = "6813065283"

    static var bundleID: String {
        Bundle.main.bundleIdentifier ?? "com.FrameOnceDailyJournal"
    }
    static var storeID: String {
        "id\(appsFlyerAppleAppID)"
    }

    static let configEndpoint = "https://frameoncedailyjournal.com/config.php"

    static let privacyPolicyAddress = "https://frameoncedailyjournal.com/privacy-policy.html"

    static let osName = "IOS"
    static let pushTokenPlaceholder = "00000000000000000000"
    static let firebaseProjectID = "378830042428"

    static let gcdRetryDelay: TimeInterval = 1.0
    static let mergeWaitInterval: TimeInterval = 3.0
    static let configRequestTimeouts: [TimeInterval] = [15, 15, 30]
    static let launchLoaderDuration: TimeInterval = 15 + 15 + 30

    static let pushPermissionRetryDelay: TimeInterval = 60 * 60 * 24 * 3

    static let pushDataAddressKey = "url"
}
