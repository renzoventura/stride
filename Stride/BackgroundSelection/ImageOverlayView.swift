//
//  ImageOverlayView.swift
//  Stride
//
//  Draggable, pinch-resizable image overlay on the editing canvas.
//  Used for gallery photos and map snapshots placed as canvas elements.
//

import SwiftUI

/// Natural display width for all image overlays before scale is applied.
private let imageOverlayBaseWidth: CGFloat = 300

struct ImageOverlayView: View {
    let item: ImageOverlayItem
    let onDragStarted: () -> Void
    let onUpdate: (CGPoint, CGFloat) -> Void

    private let minScale: CGFloat = 0.2
    private let maxScale: CGFloat = 5

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    @State private var scaleAtPinchStart: CGFloat?

    var body: some View {
        let effectivePosition = CGPoint(
            x: item.position.x + dragOffset.width,
            y: item.position.y + dragOffset.height
        )
        let aspectRatio = item.image.size.height > 0 ? item.image.size.width / item.image.size.height : 1

        Image(uiImage: item.image)
            .resizable()
            .frame(width: imageOverlayBaseWidth, height: imageOverlayBaseWidth / aspectRatio)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            .opacity(item.opacity)
            .scaleEffect(item.scale)
            .position(effectivePosition)
            .highPriorityGesture(
                MagnificationGesture()
                    .onChanged { value in
                        if scaleAtPinchStart == nil { scaleAtPinchStart = item.scale }
                        let newScale = (scaleAtPinchStart ?? item.scale) * value
                        onUpdate(item.position, newScale.clamped(to: minScale...maxScale))
                    }
                    .onEnded { _ in scaleAtPinchStart = nil }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging {
                            isDragging = true
                            onDragStarted()
                        }
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        isDragging = false
                        onUpdate(effectivePosition, item.scale)
                        dragOffset = .zero
                    }
            )
    }
}

/// Renders an image overlay for export (no gestures).
struct ImageOverlayDrawingView: View {
    let item: ImageOverlayItem

    var body: some View {
        let aspectRatio = item.image.size.height > 0 ? item.image.size.width / item.image.size.height : 1
        Image(uiImage: item.image)
            .resizable()
            .frame(width: imageOverlayBaseWidth, height: imageOverlayBaseWidth / aspectRatio)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.sm))
            .opacity(item.opacity)
            .scaleEffect(item.scale)
            .position(item.position)
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
