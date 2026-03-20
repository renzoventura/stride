//
//  EditingCanvasView.swift
//  Stride
//
//  Layer 2: The main editing canvas. Contains the zoomable image and the sticker overlay.
//  Fills all available space given to it. Clipped so content never bleeds out.
//

import SwiftUI

/// The primary interactive editing surface.
///
/// Responsibilities:
/// - Renders the zoomable/pannable base image via `ZoomableImageCanvas`.
/// - Renders draggable stickers above the image.
/// - Reports its measured size via `onCanvasSizeChange` for export.
struct EditingCanvasView: View {
    let image: UIImage
    @Binding var scaleMultiplier: CGFloat
    @Binding var offset: CGSize
    let stickers: [StickerItem]
    let imageOverlays: [ImageOverlayItem]
    let onStickerDragStarted: () -> Void
    let onStickerUpdate: (UUID, CGPoint, CGFloat) -> Void
    let onImageOverlayDragStarted: () -> Void
    let onImageOverlayUpdate: (UUID, CGPoint, CGFloat) -> Void
    let onCanvasSizeChange: (CGSize) -> Void

    var body: some View {
        ZStack {
            // Base layer: zoomable image
            ZoomableImageCanvas(
                image: image,
                scaleMultiplier: $scaleMultiplier,
                offset: $offset
            )

            // Sticker layer: rendered above the image
            stickerLayer
        }
        .clipped()
        .background(.black)
        .background {
            GeometryReader { geometry in
                Color.clear
                    .onChange(of: geometry.size) { _, newSize in
                        onCanvasSizeChange(newSize)
                    }
                    .onAppear {
                        onCanvasSizeChange(geometry.size)
                    }
            }
        }
    }

    @ViewBuilder
    private var stickerLayer: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            if canvasSize.width > 0, canvasSize.height > 0 {
                ZStack {
                    // Transparent hit-test blocker so sticker gestures don't fall through
                    Color.clear
                        .allowsHitTesting(false)

                    ForEach(stickers) { sticker in
                        StickerOverlayView(
                            sticker: sticker,
                            canvasSize: canvasSize,
                            onDragStarted: onStickerDragStarted,
                            onUpdate: { newPosition, newScale in
                                onStickerUpdate(sticker.id, newPosition, newScale)
                            }
                        )
                    }
                    ForEach(imageOverlays) { overlay in
                        ImageOverlayView(
                            item: overlay,
                            onDragStarted: onImageOverlayDragStarted,
                            onUpdate: { newPosition, newScale in
                                onImageOverlayUpdate(overlay.id, newPosition, newScale)
                            }
                        )
                    }
                }
            }
        }
    }
}
