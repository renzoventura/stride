//
//  StickerOverlayView.swift
//  Stride
//
//  Renders one sticker on the canvas with drag (reposition) and pinch (resize).
//  Routes to the appropriate layout view via StickerLayoutRouter.
//  PR stickers get a celebratory entrance animation with a glow pulse.
//

import SwiftUI

struct StickerOverlayView: View {
    let sticker: StickerItem
    let canvasSize: CGSize
    let onUpdate: (CGPoint, CGFloat) -> Void

    private let minScale: CGFloat = 0.4
    private let maxScale: CGFloat = 3

    @State private var dragOffset: CGSize = .zero
    @State private var scaleAtPinchStart: CGFloat?
    @State private var appeared = false
    @State private var glowActive = false

    var body: some View {
        let effectivePosition = CGPoint(
            x: sticker.position.x + dragOffset.width,
            y: sticker.position.y + dragOffset.height
        )

        StickerLayoutRouter(layoutType: sticker.layoutType, data: sticker.data)
            .fixedSize()
            .shadow(
                color: sticker.layoutType.isPR && glowActive
                    ? AppColors.accent.opacity(0.5)
                    : .clear,
                radius: glowActive ? 16 : 0
            )
            .scaleEffect(sticker.scale * (appeared ? 1 : 0.7))
            .opacity(appeared ? 1 : 0)
            .position(effectivePosition)
            .highPriorityGesture(
                MagnificationGesture()
                    .onChanged { value in
                        if scaleAtPinchStart == nil {
                            scaleAtPinchStart = sticker.scale
                        }
                        let newScale = (scaleAtPinchStart ?? sticker.scale) * value
                        onUpdate(sticker.position, newScale.clamped(to: minScale...maxScale))
                    }
                    .onEnded { _ in
                        scaleAtPinchStart = nil
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        onUpdate(effectivePosition, sticker.scale)
                        dragOffset = .zero
                    }
            )
            .onAppear {
                withAnimation(.spring(duration: 0.45, bounce: 0.35)) {
                    appeared = true
                }
                if sticker.layoutType.isPR {
                    withAnimation(.easeOut(duration: 0.5).delay(0.15)) {
                        glowActive = true
                    }
                    withAnimation(.easeOut(duration: 0.6).delay(0.8)) {
                        glowActive = false
                    }
                }
            }
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

/// Renders a single sticker for export (no gestures, no animation).
struct StickerDrawingView: View {
    let sticker: StickerItem

    var body: some View {
        StickerLayoutRouter(layoutType: sticker.layoutType, data: sticker.data)
            .fixedSize()
            .scaleEffect(sticker.scale)
            .position(sticker.position)
    }
}
