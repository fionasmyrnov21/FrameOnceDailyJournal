import SwiftUI

struct FirstRunHintView: View {
    var onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(alignment: .leading, spacing: 14) {
                Text("FrameOnce")
                    .font(AppTheme.display(28))
                    .foregroundStyle(AppTheme.parchment)
                Text("Capture one frame. Give it meaning. Keep a quiet journal of days.")
                    .font(AppTheme.chromeFont(15))
                    .foregroundStyle(AppTheme.mist)
                    .fixedSize(horizontal: false, vertical: true)
                Button {
                    onDismiss()
                } label: {
                    Text("Begin")
                        .font(AppTheme.chromeFont(16, weight: .semibold))
                        .foregroundStyle(AppTheme.graphite)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.warmAccent)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .padding(.top, 4)
            }
            .padding(22)
            .background(AppTheme.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(AppTheme.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 28)
        }
    }
}
