import SwiftUI

struct CaptureView: View {
    @ObservedObject var viewModel: CaptureViewModel

    var body: some View {
        ZStack {
            AppBackground()

            switch viewModel.camera.state {
            case .unauthorized:
                unauthorizedContent
            case .failed(let message):
                statusMessage(message)
            case .configuring:
                statusMessage("Preparing camera…")
            case .ready:
                readyContent
            }

            if viewModel.isAnalyzing {
                AnalyzingOverlay()
                    .transition(.opacity)
            }

            if viewModel.showFirstRunHint {
                FirstRunHintView {
                    viewModel.dismissFirstRunHint()
                }
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.isAnalyzing)
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .fullScreenCover(isPresented: $viewModel.showCompose) {
            if let payload = viewModel.composePayload {
                ComposeView(
                    viewModel: ComposeViewModel(payload: payload, store: viewModel.store),
                    onRetake: {
                        viewModel.showCompose = false
                        viewModel.composePayload = nil
                    },
                    onSaved: {
                        viewModel.didCompleteSave = true
                        viewModel.showCompose = false
                        viewModel.composePayload = nil
                    }
                )
            }
        }
    }

    private var readyContent: some View {
        DuoAdaptiveArrangement {
            ZStack {
                CameraPreviewView(session: viewModel.camera.session)
                    .ignoresSafeArea()
                ViewfinderFrame()
                    .padding(8)
            }
            .overlay(alignment: .top) {
                VStack(spacing: 8) {
                    Text("One frame. One meaning.")
                        .font(AppTheme.title(18))
                        .foregroundStyle(AppTheme.parchment)
                    Text("\(viewModel.framesToday) frames today")
                        .font(AppTheme.caption(12, weight: .semibold))
                        .foregroundStyle(AppTheme.mist)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(AppTheme.surface.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(AppTheme.hairline, lineWidth: 1)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(.top, 12)
            }
        } secondary: {
            captureControls
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(AppTheme.surface.opacity(0.94))
        }
    }

    private var captureControls: some View {
        VStack(spacing: 18) {
            HStack {
                Text("Ready")
                    .font(AppTheme.caption(12, weight: .semibold))
                    .foregroundStyle(AppTheme.mist)
                Spacer()
                Circle()
                    .fill(AppTheme.warmAccent)
                    .frame(width: 8, height: 8)
            }
            .padding(.horizontal, 4)

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(AppTheme.chromeFont(13))
                    .foregroundStyle(AppTheme.warmAccent)
            }
            HStack(spacing: 36) {
                Button {
                    viewModel.flip()
                } label: {
                    Label("Flip", systemImage: "arrow.triangle.2.circlepath.camera")
                        .labelStyle(.iconOnly)
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(AppTheme.parchment)
                        .frame(width: 48, height: 48)
                }
                .accessibilityLabel("Flip camera")

                Button {
                    viewModel.capture()
                } label: {
                    ZStack {
                        Circle()
                            .stroke(AppTheme.parchment, lineWidth: 3)
                            .frame(width: 74, height: 74)
                        Circle()
                            .fill(viewModel.isCapturing ? AppTheme.warmAccent.opacity(0.6) : AppTheme.parchment)
                            .frame(width: 60, height: 60)
                    }
                    .scaleEffect(viewModel.shutterPulse ? 0.88 : 1.0)
                    .animation(.spring(response: 0.22, dampingFraction: 0.55), value: viewModel.shutterPulse)
                }
                .disabled(viewModel.isCapturing || viewModel.isAnalyzing)
                .accessibilityLabel("Capture frame")

                Color.clear.frame(width: 48, height: 48)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }

    private var unauthorizedContent: some View {
        VStack(spacing: 16) {
            Text("Camera Access Needed")
                .font(AppTheme.display(24))
                .foregroundStyle(AppTheme.parchment)
            Text("Allow camera access to capture a single frame for your daily card.")
                .font(AppTheme.chromeFont(15))
                .foregroundStyle(AppTheme.mist)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
            Button("Open Settings") {
                viewModel.openSystemSettings()
            }
            .font(AppTheme.chromeFont(16, weight: .semibold))
            .foregroundStyle(AppTheme.graphite)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(AppTheme.warmAccent)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func statusMessage(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.chromeFont(16))
            .foregroundStyle(AppTheme.parchment)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
