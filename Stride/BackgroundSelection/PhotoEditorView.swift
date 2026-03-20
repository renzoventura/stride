//
//  PhotoEditorView.swift
//  Stride
//
//  Composition root for the photo editor screen.
//
//  Layer order (back → front):
//    1. Safe area management  – handled by the root layout
//    2. EditingCanvasView     – zoomable image + stickers
//    3. EditorBottomActionView – fixed bottom controls
//    4. EditorOverlayButtons  – floating close & add-sticker buttons
//

import SwiftUI
import Photos
import UIKit
import MapKit

// MARK: - Shareable wrapper

/// Wraps UIImage for use with `.sheet(item:)`.
struct ShareableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}

// MARK: - PhotoEditorView

struct PhotoEditorView: View {
    let runItem: RunFeedItem
    let image: UIImage
    let onDismiss: () -> Void

    // MARK: Canvas state

    @State private var scaleMultiplier: CGFloat = 1
    @State private var offset: CGSize = .zero
    @State private var stickers: [StickerItem] = []
    @State private var imageOverlays: [ImageOverlayItem] = []
    @State private var canvasSize: CGSize = .zero

    // MARK: UI state

    @State private var showStickerPicker = false
    @State private var showGalleryPicker = false
    @State private var isSaving = false
    @State private var saveSuccess = false
    @State private var shareItem: ShareableImage?
    @State private var isDraggingSticker = false

    @Environment(\.displayScale) private var displayScale

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            EditingCanvasView(
                image: image,
                scaleMultiplier: $scaleMultiplier,
                offset: $offset,
                stickers: stickers,
                imageOverlays: imageOverlays,
                onStickerDragStarted: {
                    withAnimation(.spring(duration: 0.25)) { isDraggingSticker = true }
                },
                onStickerUpdate: { id, position, scale in
                    updateSticker(id: id, position: position, scale: scale)
                },
                onImageOverlayDragStarted: {
                    withAnimation(.spring(duration: 0.25)) { isDraggingSticker = true }
                },
                onImageOverlayUpdate: { id, position, scale in
                    updateImageOverlay(id: id, position: position, scale: scale)
                },
                onCanvasSizeChange: { newSize in
                    canvasSize = newSize
                }
            )

            EditorBottomActionView(
                isSaving: isSaving,
                onShare: { exportAndShare() },
                onSave: { saveToPhotoLibrary() },
                onStory: { shareToInstagramStory() }
            )
        }
        .background {
            AppColors.background.ignoresSafeArea()
        }
        .overlay {
            EditorOverlayButtons(
                bottomBarHeight: EditorBottomActionView.height,
                isDraggingSticker: isDraggingSticker,
                onClose: onDismiss,
                onAddSticker: { showStickerPicker = true },
                onOpenGallery: { showGalleryPicker = true },
                onAddMap4x5: { addMapOverlay(size: CGSize(width: 800, height: 1000)) },
                onAddMap1x1: { addMapOverlay(size: CGSize(width: 800, height: 800)) }
            )
        }
        .overlay {
            if saveSuccess {
                savedFeedbackBadge
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $shareItem) { shareable in
            ShareSheetView(activityItems: [shareable.image])
                .onDisappear { shareItem = nil }
        }
        .sheet(isPresented: $showStickerPicker) {
            StickerPickerView(
                data: runItem.stickerData,
                options: runItem.stickerOptions,
                onSelect: { addSticker(option: $0) },
                onDismiss: { showStickerPicker = false }
            )
        }
        .sheet(isPresented: $showGalleryPicker) {
            PHPickerRepresentable { image in
                guard let image else { return }
                addImageOverlay(image: image)
            }
        }
    }

    // MARK: - Sub-views

    private var savedFeedbackBadge: some View {
        Text("Saved")
            .font(AppFont.secondary)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(AppColors.surfaceElevated, in: .capsule)
            .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    // MARK: - Sticker management

    private func addSticker(option: RunStickerOption) {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        stickers.append(StickerItem(
            layoutType: option.layoutType,
            data: runItem.stickerData,
            position: center
        ))
    }

    private func updateSticker(id: UUID, position: CGPoint, scale: CGFloat) {
        defer {
            withAnimation(.spring(duration: 0.25)) { isDraggingSticker = false }
        }
        if isDraggingSticker && isInTrashZone(position) {
            stickers.removeAll { $0.id == id }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        guard let index = stickers.firstIndex(where: { $0.id == id }) else { return }
        stickers[index].position = position
        stickers[index].scale = scale
    }

    private func isInTrashZone(_ point: CGPoint) -> Bool {
        // Trash button sits at bottom-center, buttonRadius(26) + md(16) above the canvas bottom
        let trashCenter = CGPoint(x: canvasSize.width / 2, y: canvasSize.height - 42)
        let dx = point.x - trashCenter.x
        let dy = point.y - trashCenter.y
        return sqrt(dx * dx + dy * dy) < 60
    }

    private func updateImageOverlay(id: UUID, position: CGPoint, scale: CGFloat) {
        defer {
            withAnimation(.spring(duration: 0.25)) { isDraggingSticker = false }
        }
        if isDraggingSticker && isInTrashZone(position) {
            imageOverlays.removeAll { $0.id == id }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            return
        }
        guard let index = imageOverlays.firstIndex(where: { $0.id == id }) else { return }
        imageOverlays[index].position = position
        imageOverlays[index].scale = scale
    }

    private func addImageOverlay(image: UIImage, opacity: Double = 1) {
        let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
        let initialScale = canvasSize.width > 0 ? (canvasSize.width * 0.5) / 300 : 1
        imageOverlays.append(ImageOverlayItem(image: image, position: center, scale: initialScale, opacity: opacity))
    }

    private func addMapOverlay(size: CGSize) {
        guard let polyline = runItem.polyline, !polyline.isEmpty else { return }
        Task {
            guard let mapImage = await MapSnapshotService.makeSnapshot(
                polyline: polyline,
                size: size,
                routeLineWidth: 4
            ) else { return }
            await MainActor.run { addImageOverlay(image: mapImage, opacity: 0.75) }
        }
    }

    // MARK: - Export

    private func exportImage() -> UIImage? {
        guard canvasSize.width > 0, canvasSize.height > 0 else { return nil }
        let content = ExportCanvasContent(
            image: image,
            scale: scaleMultiplier,
            offset: offset,
            stickers: stickers,
            imageOverlays: imageOverlays,
            canvasSize: canvasSize
        )
        let renderer = ImageRenderer(content: content)
        renderer.scale = displayScale
        return renderer.uiImage
    }

    private func saveToPhotoLibrary() {
        guard let rendered = exportImage() else { return }
        isSaving = true
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            Task { @MainActor in
                defer { isSaving = false }
                guard status == .authorized || status == .limited else { return }
                guard let imageData = rendered.jpegData(compressionQuality: 1) else { return }
                PHPhotoLibrary.shared().performChanges {
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, data: imageData, options: nil)
                } completionHandler: { success, _ in
                    Task { @MainActor in
                        if success {
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            withAnimation(.easeOut(duration: 0.2)) { saveSuccess = true }
                            Task {
                                try? await Task.sleep(for: .seconds(1.5))
                                withAnimation { saveSuccess = false }
                            }
                        }
                    }
                }
            }
        }
    }

    private func exportAndShare() {
        guard let rendered = exportImage() else { return }
        shareItem = ShareableImage(image: rendered)
    }

    private func shareToInstagramStory() {
        guard let rendered = exportImage(),
              let imageData = rendered.pngData() else { return }

        let pasteboardItems: [[String: Any]] = [
            ["com.instagram.sharedSticker.backgroundImage": imageData]
        ]
        let pasteboardOptions: [UIPasteboard.OptionsKey: Any] = [
            .expirationDate: Date().addingTimeInterval(5 * 60)
        ]
        UIPasteboard.general.setItems(pasteboardItems, options: pasteboardOptions)

        guard let url = URL(string: "instagram-stories://share?source_application=com.Stride") else { return }
        UIApplication.shared.open(url)
    }
}

// MARK: - Share sheet

/// Wraps UIActivityViewController for sharing.
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PhotoEditorView(
            runItem: RunFeedItem(
                id: 1,
                distanceKm: 5.42,
                pacePerKmDisplay: "5:17",
                movingTimeSeconds: 1924,
                dateDisplay: "Jan 15, 2026",
                locationDisplay: "San Francisco, CA",
                polyline: nil
            ),
            image: UIImage(systemName: "photo")!,
            onDismiss: {}
        )
    }
}
