import SwiftUI

enum AppTheme {
    static let graphite = Color(red: 0.12, green: 0.13, blue: 0.15)
    static let graphiteSoft = Color(red: 0.18, green: 0.19, blue: 0.22)
    static let parchment = Color(red: 0.93, green: 0.90, blue: 0.84)
    static let warmAccent = Color(red: 0.82, green: 0.52, blue: 0.28)
    static let mist = Color(red: 0.68, green: 0.72, blue: 0.76)

    static let surface = Color(red: 0.15, green: 0.16, blue: 0.18)
    static let surfaceElevated = Color(red: 0.20, green: 0.21, blue: 0.24)
    static let hairline = Color(red: 0.42, green: 0.40, blue: 0.36).opacity(0.55)
    static let accentMuted = Color(red: 0.82, green: 0.52, blue: 0.28).opacity(0.28)

    static func display(_ size: CGFloat = 32) -> Font {
        .system(size: size, design: .serif)
    }

    static func title(_ size: CGFloat = 22) -> Font {
        .system(size: size, design: .serif)
    }

    static func caption(_ size: CGFloat = 13, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    static func cardTitleFont(_ size: CGFloat = 22) -> Font {
        title(size)
    }

    static func chromeFont(_ size: CGFloat = 15, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .default)
    }
}

struct AppBackground: View {
    var body: some View {
        ZStack {
            AppTheme.graphite
            RadialGradient(
                colors: [
                    AppTheme.warmAccent.opacity(0.14),
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 420
            )
            LinearGradient(
                colors: [
                    Color.black.opacity(0.18),
                    Color.clear,
                    Color.black.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

enum HapticFeedback {
    static func light() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
