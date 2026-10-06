import SwiftUI
import UIKit

struct ProfileView: View {
    @ObservedObject private var profile = PlayerProfileStore.shared
    @State private var draftName: String = ""
    @State private var showCamera = false
    @State private var cameraUnavailable = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Button {
                    openCamera()
                } label: {
                    ZStack {
                        Circle()
                            .fill(AppTheme.surfaceElevated)
                            .frame(width: 120, height: 120)
                        if let avatar = profile.avatarImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(AppTheme.warmAccent)
                        }
                    }
                    .overlay(
                        Circle()
                            .stroke(AppTheme.hairline, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Text("Tap to capture a profile photo")
                    .font(AppTheme.chromeFont(13))
                    .foregroundStyle(AppTheme.mist)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Display name")
                        .font(AppTheme.caption(12, weight: .medium))
                        .foregroundStyle(AppTheme.mist)
                    TextField("Your name", text: $draftName)
                        .font(AppTheme.chromeFont(16))
                        .foregroundStyle(AppTheme.parchment)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(AppTheme.surface)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(AppTheme.hairline, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .onChange(of: draftName) { value in
                            profile.updateDisplayName(value)
                        }
                }

                if profile.avatarImage != nil {
                    Button("Remove photo") {
                        profile.clearAvatar()
                    }
                    .font(AppTheme.chromeFont(14, weight: .medium))
                    .foregroundStyle(AppTheme.warmAccent)
                }
            }
            .padding(20)
        }
        .background { AppBackground() }
        .navigationTitle("Profile")
        .toolbarBackground(AppTheme.surface, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            draftName = profile.displayName
        }
        .sheet(isPresented: $showCamera) {
            ProfileCameraPicker { image in
                if let image {
                    profile.saveAvatar(image)
                }
                showCamera = false
            }
            .ignoresSafeArea()
        }
        .alert("Camera Unavailable", isPresented: $cameraUnavailable) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("This device cannot open the camera for a profile photo.")
        }
    }

    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            cameraUnavailable = true
            return
        }
        showCamera = true
    }
}

private struct ProfileCameraPicker: UIViewControllerRepresentable {
    var onFinished: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinished: onFinished)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onFinished: (UIImage?) -> Void

        init(onFinished: @escaping (UIImage?) -> Void) {
            self.onFinished = onFinished
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            onFinished(nil)
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
            onFinished(image)
        }
    }
}
