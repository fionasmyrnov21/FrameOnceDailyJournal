import Combine
import SwiftUI
import UIKit

final class CaptureViewModel: ObservableObject {
    @Published var isCapturing = false
    @Published var isAnalyzing = false
    @Published var shutterPulse = false
    @Published var composePayload: ComposePayload?
    @Published var showCompose = false
    @Published var errorMessage: String?
    @Published var showFirstRunHint = false
    @Published var didCompleteSave = false

    let camera: CameraCaptureService
    let store: FrameCardStore
    private let insightEngine = SceneInsightEngine()
    private let composer = CardComposer()

    private static let firstRunKey = "didShowFirstRunHint"

    struct ComposePayload: Identifiable {
        let id = UUID()
        let image: UIImage
        let imageData: Data
        let insight: SceneInsight
        var atmosphereId: String
    }

    init(store: FrameCardStore, camera: CameraCaptureService? = nil) {
        self.store = store
        self.camera = camera ?? CameraCaptureService()
        showFirstRunHint = !UserDefaults.standard.bool(forKey: Self.firstRunKey)
    }

    var framesToday: Int {
        store.framesTodayCount()
    }

    func dismissFirstRunHint() {
        showFirstRunHint = false
        UserDefaults.standard.set(true, forKey: Self.firstRunKey)
    }

    func onAppear() {
        camera.prepare()
    }

    func onDisappear() {
        camera.stop()
    }

    func flip() {
        camera.flipCamera()
    }

    func openSystemSettings() {
        guard let destination = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(destination)
    }

    func capture() {
        guard !isCapturing, !isAnalyzing else { return }
        isCapturing = true
        errorMessage = nil
        HapticFeedback.light()
        withAnimation(.easeOut(duration: 0.12)) {
            shutterPulse = true
        }
        Task {
            defer {
                Task { @MainActor in
                    withAnimation(.easeOut(duration: 0.2)) {
                        shutterPulse = false
                    }
                    isCapturing = false
                }
            }
            guard let image = await camera.capturePhoto() else {
                await MainActor.run {
                    errorMessage = "Capture failed. Try again."
                }
                return
            }
            guard let data = composer.jpegData(from: image) else {
                await MainActor.run {
                    errorMessage = "Could not prepare the frame."
                }
                return
            }
            await MainActor.run {
                isAnalyzing = true
            }
            let insight = await insightEngine.analyze(image: image)
            let defaultAtmosphere = store.preferredAtmosphereId
            await MainActor.run {
                composePayload = ComposePayload(
                    image: image,
                    imageData: data,
                    insight: insight,
                    atmosphereId: defaultAtmosphere
                )
                isAnalyzing = false
                showCompose = true
            }
        }
    }
}
