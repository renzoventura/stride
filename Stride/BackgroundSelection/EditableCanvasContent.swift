//
//  EditableCanvasContent.swift
//  Stride
//
//  Renders the image at given scale and offset inside a fixed frame. Used for display and export.
//

import SwiftUI
import UIKit

/// Renders exactly what the user sees in the editor canvas: image at scale and offset, clipped to frame.
struct EditableCanvasContent: View {
    let image: UIImage
    let scale: CGFloat
    let offset: CGSize
    let canvasSize: CGSize

    private var imageSize: CGSize {
        CGSize(width: image.size.width, height: image.size.height)
    }

    /// Scale to fill the canvas (aspect fill).
    private var fillScale: CGFloat {
        guard imageSize.width > 0, imageSize.height > 0 else { return 1 }
        return max(canvasSize.width / imageSize.width, canvasSize.height / imageSize.height)
    }

    private var displaySize: CGSize {
        let s = fillScale * scale
        return CGSize(width: imageSize.width * s, height: imageSize.height * s)
    }

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: displaySize.width, height: displaySize.height)
            .offset(offset)
            .frame(width: canvasSize.width, height: canvasSize.height)
            .clipped()
    }
}

/// Renders image + sticker overlays for export (Save/Share).
struct ExportCanvasContent: View {
    let image: UIImage
    let scale: CGFloat
    let offset: CGSize
    let stickers: [StickerItem]
    let imageOverlays: [ImageOverlayItem]
    let canvasSize: CGSize

    var body: some View {
        ZStack {
            EditableCanvasContent(
                image: image,
                scale: scale,
                offset: offset,
                canvasSize: canvasSize
            )
            ForEach(imageOverlays) { overlay in
                ImageOverlayDrawingView(item: overlay)
            }
            ForEach(stickers) { sticker in
                StickerDrawingView(sticker: sticker)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }
}
