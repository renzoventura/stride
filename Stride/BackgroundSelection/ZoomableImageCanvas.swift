//
//  ZoomableImageCanvas.swift
//  Stride
//
//  Full-screen canvas: image with pinch-to-zoom (0.25x–4x) and free pan (can drag off-screen, cropped by canvas).
//

import SwiftUI

struct ZoomableImageCanvas: View {
    let image: UIImage
    @Binding var scaleMultiplier: CGFloat
    @Binding var offset: CGSize

    private let maxZoomMultiplier: CGFloat = 4
    private let minZoomMultiplier: CGFloat = 0.25

    @State private var scaleAtPinchStart: CGFloat?
    @State private var dragTranslation: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let canvasSize = geometry.size
            let clampedMultiplier = scaleMultiplier.clamped(to: minZoomMultiplier...maxZoomMultiplier)
            let effectiveOffset = CGSize(
                width: offset.width + dragTranslation.width,
                height: offset.height + dragTranslation.height
            )

            EditableCanvasContent(
                image: image,
                scale: clampedMultiplier,
                offset: effectiveOffset,
                canvasSize: canvasSize
            )
            .frame(width: canvasSize.width, height: canvasSize.height)
            .contentShape(.rect)
            .highPriorityGesture(
                MagnificationGesture()
                    .onChanged { value in
                        if scaleAtPinchStart == nil {
                            scaleAtPinchStart = scaleMultiplier
                        }
                        let newScale = (scaleAtPinchStart ?? scaleMultiplier) * value
                        scaleMultiplier = newScale.clamped(to: minZoomMultiplier...maxZoomMultiplier)
                    }
                    .onEnded { _ in
                        scaleAtPinchStart = nil
                    }
            )
            .simultaneousGesture(
                DragGesture()
                    .onChanged { value in
                        dragTranslation = value.translation
                    }
                    .onEnded { _ in
                        offset = effectiveOffset
                        dragTranslation = .zero
                    }
            )
        }
        .background(.gray)
    }

    private func fillScaleForCanvas(_ canvasSize: CGSize) -> CGFloat {
        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return 1 }
        return max(canvasSize.width / imageSize.width, canvasSize.height / imageSize.height)
    }

    private func displaySizeForMultiplier(_ multiplier: CGFloat, canvasSize: CGSize) -> CGSize {
        let fillScale = fillScaleForCanvas(canvasSize)
        let imageSize = image.size
        let s = fillScale * multiplier
        return CGSize(width: imageSize.width * s, height: imageSize.height * s)
    }

}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
