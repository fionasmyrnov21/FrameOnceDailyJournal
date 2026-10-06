import SwiftUI

struct DuoSplitContainer<Primary: View, Secondary: View>: View {
    @ViewBuilder var primary: () -> Primary
    @ViewBuilder var secondary: () -> Secondary

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        GeometryReader { proxy in
            let useSideBySide = shouldSplit(width: proxy.size.width, height: proxy.size.height)
            if useSideBySide {
                HStack(spacing: 0) {
                    primary()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    secondary()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                VStack(spacing: 0) {
                    primary()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    secondary()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
    }

    private func shouldSplit(width: CGFloat, height: CGFloat) -> Bool {
        if horizontalSizeClass == .regular, width > height {
            return true
        }
        return width >= 700 && width > height
    }
}

enum DuoGridLayout {
    static func columnCount(for horizontalSizeClass: UserInterfaceSizeClass?) -> Int {
        horizontalSizeClass == .regular ? 4 : 2
    }
}

struct DuoAdaptiveArrangement<Primary: View, Secondary: View>: View {
    @ViewBuilder var primary: () -> Primary
    @ViewBuilder var secondary: () -> Secondary

    var body: some View {
        if #available(iOS 27.1, *) {
            duoSplitBody
        } else {
            duoSplitBody
        }
    }

    private var duoSplitBody: some View {
        DuoSplitContainer(primary: primary, secondary: secondary)
    }
}
