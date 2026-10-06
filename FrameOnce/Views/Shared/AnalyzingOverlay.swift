import SwiftUI

struct AnalyzingOverlay: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .stroke(AppTheme.parchment.opacity(0.7), lineWidth: 1.5)
                    .frame(width: 64, height: 80)
                    .overlay(
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                            .fill(AppTheme.warmAccent.opacity(pulse ? 0.55 : 0.2))
                            .padding(10)
                    )
                    .scaleEffect(pulse ? 1.04 : 0.96)

                Text("Reading the frame…")
                    .font(AppTheme.title(20))
                    .foregroundStyle(AppTheme.parchment)
            }
            .padding(28)
            .background(AppTheme.surfaceElevated.opacity(0.95))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}
