import SwiftUI

struct AtmosphereStyledImage: View {
    let image: UIImage?
    let atmosphere: VisualAtmosphere

    var body: some View {
        ZStack {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .contrast(1.0 + atmosphere.contrastBoost)
            } else {
                AppTheme.graphiteSoft
            }
            atmosphere.overlayColor
                .opacity(atmosphere.overlayOpacity)
            FilmGrainOverlay(opacity: max(0.1, atmosphere.grainOpacity * 1.35))
            FilmVignette(intensity: 0.28 + atmosphere.grainOpacity * 0.55)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(atmosphere.grainOpacity * 0.2),
                            Color.clear,
                            Color.black.opacity(0.18 + atmosphere.grainOpacity * 0.45)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.overlay)
                .allowsHitTesting(false)
        }
        .clipped()
        .overlay(
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .stroke(atmosphere.frameTone.opacity(0.55), lineWidth: 1)
        )
    }
}

struct AssociationChips: View {
    let associations: [String]

    var body: some View {
        FlowWrap(items: associations.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) { text in
            Text(text)
                .font(AppTheme.chromeFont(13))
                .foregroundStyle(AppTheme.parchment.opacity(0.9))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        }
    }
}

struct EditableAssociationFields: View {
    @Binding var associations: [String]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<2, id: \.self) { index in
                TextField(
                    index == 0 ? "First association" : "Second association",
                    text: binding(at: index)
                )
                .font(AppTheme.chromeFont(14))
                .foregroundStyle(AppTheme.parchment)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(AppTheme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
    }

    private func binding(at index: Int) -> Binding<String> {
        Binding(
            get: {
                if associations.indices.contains(index) {
                    return associations[index]
                }
                return ""
            },
            set: { newValue in
                var next = associations
                while next.count < 2 {
                    next.append("")
                }
                next[index] = newValue
                associations = Array(next.prefix(2))
            }
        )
    }
}

struct FlowWrap<Item: Hashable, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Item) -> Content

    @State private var totalHeight: CGFloat = .zero

    var body: some View {
        GeometryReader { geometry in
            generateContent(in: geometry)
        }
        .frame(height: totalHeight)
    }

    private func generateContent(in geometry: GeometryProxy) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(items, id: \.self) { item in
                content(item)
                    .padding([.trailing, .bottom], 8)
                    .alignmentGuide(.leading) { dimension in
                        if abs(width - dimension.width) > geometry.size.width {
                            width = 0
                            height -= dimension.height
                        }
                        let result = width
                        if item == items.last {
                            width = 0
                        } else {
                            width -= dimension.width
                        }
                        return result
                    }
                    .alignmentGuide(.top) { _ in
                        let result = height
                        if item == items.last {
                            height = 0
                        }
                        return result
                    }
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear.preference(key: HeightPreferenceKey.self, value: proxy.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self) { totalHeight = $0 }
    }
}

private struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

struct AtmosphereStrip: View {
    let atmospheres: [VisualAtmosphere]
    @Binding var selectedId: String

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(atmospheres) { atmosphere in
                    Button {
                        selectedId = atmosphere.id
                    } label: {
                        VStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(atmosphere.overlayColor)
                                    .frame(width: 28, height: 28)
                                if selectedId == atmosphere.id {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundStyle(AppTheme.parchment)
                                }
                            }
                            .overlay(
                                Circle()
                                    .stroke(
                                        selectedId == atmosphere.id ? AppTheme.warmAccent : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                            Text(atmosphere.name)
                                .font(AppTheme.chromeFont(11))
                                .foregroundStyle(AppTheme.parchment.opacity(0.85))
                                .lineLimit(1)
                        }
                        .frame(width: 72)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
        }
    }
}
