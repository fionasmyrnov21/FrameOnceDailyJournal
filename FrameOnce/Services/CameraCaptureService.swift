@preconcurrency import AVFoundation
import Combine
import SwiftUI
import UIKit

enum CameraCaptureState: Equatable {
    case unauthorized
    case configuring
    case ready
    case failed(String)
}

final class CameraCaptureService: NSObject, ObservableObject, @unchecked Sendable {
    @Published private(set) var state: CameraCaptureState = .configuring
    @Published private(set) var capturedImage: UIImage?
    @Published private(set) var isUsingFrontCamera = false

    let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "com.frameonce.camera.session")
    private let photoOutput = AVCapturePhotoOutput()
    private var videoDeviceInput: AVCaptureDeviceInput?
    private var photoContinuation: CheckedContinuation<UIImage?, Never>?

    func prepare() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard let self else { return }
                Task { @MainActor in
                    if granted {
                        self.configureSession()
                    } else {
                        self.state = .unauthorized
                    }
                }
            }
        default:
            state = .unauthorized
        }
    }

    func start() {
        sessionQueue.async { [session] in
            guard !session.isRunning else { return }
            session.startRunning()
        }
    }

    func stop() {
        sessionQueue.async { [session] in
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }

    func flipCamera() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            defer { self.session.commitConfiguration() }

            if let current = self.videoDeviceInput {
                self.session.removeInput(current)
            }

            let nextPosition: AVCaptureDevice.Position = self.isUsingFrontCamera ? .back : .front
            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: nextPosition),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                Task { @MainActor in
                    self.state = .failed("Unable to switch camera.")
                }
                return
            }

            self.session.addInput(input)
            self.videoDeviceInput = input
            Task { @MainActor in
                self.isUsingFrontCamera = nextPosition == .front
            }
        }
    }

    func capturePhoto() async -> UIImage? {
        guard state == .ready else { return nil }
        return await withCheckedContinuation { continuation in
            photoContinuation = continuation
            sessionQueue.async { [weak self] in
                guard let self else { return }
                let settings = AVCapturePhotoSettings()
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
    }

    private func configureSession() {
        state = .configuring
        sessionQueue.async { [weak self] in
            guard let self else { return }
            self.session.beginConfiguration()
            self.session.sessionPreset = .photo

            self.session.inputs.forEach { self.session.removeInput($0) }
            self.session.outputs.forEach { self.session.removeOutput($0) }

            guard
                let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                let input = try? AVCaptureDeviceInput(device: device),
                self.session.canAddInput(input)
            else {
                self.session.commitConfiguration()
                Task { @MainActor in
                    self.state = .failed("Camera unavailable.")
                }
                return
            }

            self.session.addInput(input)
            self.videoDeviceInput = input

            guard self.session.canAddOutput(self.photoOutput) else {
                self.session.commitConfiguration()
                Task { @MainActor in
                    self.state = .failed("Photo output unavailable.")
                }
                return
            }

            self.session.addOutput(self.photoOutput)
            self.session.commitConfiguration()

            Task { @MainActor in
                self.isUsingFrontCamera = false
                self.state = .ready
                self.start()
            }
        }
    }
}

extension CameraCaptureService: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        let image: UIImage?
        if error == nil, let data = photo.fileDataRepresentation() {
            image = UIImage(data: data)
        } else {
            image = nil
        }
        Task { @MainActor in
            capturedImage = image
            photoContinuation?.resume(returning: image)
            photoContinuation = nil
        }
    }
}

struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.videoPreviewLayer.session = session
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        uiView.videoPreviewLayer.session = session
    }

    final class PreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            layer as! AVCaptureVideoPreviewLayer
        }
    }
}
