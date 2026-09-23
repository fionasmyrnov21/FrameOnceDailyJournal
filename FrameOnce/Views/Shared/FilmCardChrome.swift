import SwiftUI

struct FilmGrainOverlay: View {
    var opacity: Double = 0.12

    var body: some View {
        Canvas { context, size in
            let step: CGFloat = 3
            var y: CGFloat = 0
            while y < size.height {
                var x: CGFloat = 0
                while x < size.width {
                    let seed = Int(x * 17 + y * 31)
                    let shade = Double((seed * 2654435761) % 255) / 255.0
                    let rect = CGRect(x: x, y: y, width: 1.2, height: 1.2)
                    context.fill(
                        Path(ellipseIn: rect),
                        with: .color(Color.white.opacity(shade * opacity))
                    )
                    x += step
                }
                y += step
            }
        }
        .allowsHitTesting(false)
        .blendMode(.overlay)
    }
}

struct FilmVignette: View {
    var intensity: Double = 0.42

    var body: some View {
        RadialGradient(
            colors: [
                Color.clear,
                Color.black.opacity(intensity)
            ],
            center: .center,
            startRadius: 40,
            endRadius: 280
        )
        .allowsHitTesting(false)
    }
}

struct FilmCardChrome<Content: View>: View {
    let date: Date
    var title: String? = nil
    var showStamp: Bool = true
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            content()
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))

            HStack(alignment: .firstTextBaseline) {
                if let title, !title.isEmpty {
                    Text(title)
                        .font(AppTheme.title(18))
                        .foregroundStyle(AppTheme.parchment)
                        .lineLimit(2)
                }
                Spacer(minLength: 8)
                if showStamp {
                    Text(date.formatted(.dateTime.month(.abbreviated).day().year()))
                        .font(AppTheme.caption(11, weight: .medium))
                        .foregroundStyle(AppTheme.mist)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                .stroke(AppTheme.hairline, lineWidth: 1)
                        )
                }
            }
        }
        .padding(14)
        .background(AppTheme.surfaceElevated)
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: Color.black.opacity(0.35), radius: 14, x: 0, y: 8)
        .overlay {
            FilmGrainOverlay(opacity: 0.07)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
    }
}

struct ViewfinderFrame: View {
    var body: some View {
        GeometryReader { proxy in
            let inset: CGFloat = 18
            let mark: CGFloat = 28
            let rect = CGRect(
                x: inset,
                y: inset,
                width: proxy.size.width - inset * 2,
                height: proxy.size.height - inset * 2
            )
            Path { path in
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + mark))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.minX + mark, y: rect.minY))

                path.move(to: CGPoint(x: rect.maxX - mark, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + mark))

                path.move(to: CGPoint(x: rect.minX, y: rect.maxY - mark))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX + mark, y: rect.maxY))

                path.move(to: CGPoint(x: rect.maxX - mark, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - mark))
            }
            .stroke(AppTheme.parchment.opacity(0.85), lineWidth: 2)
        }
        .allowsHitTesting(false)
    }
}

struct SectionCard<Content: View>: View {
    let title: String
    let systemImage: String
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: systemImage)
                .font(AppTheme.chromeFont(15, weight: .semibold))
                .foregroundStyle(AppTheme.parchment)
            content()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfaceElevated)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(AppTheme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
