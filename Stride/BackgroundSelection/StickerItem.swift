//
//  StickerItem.swift
//  Stride
//
//  Model for a sticker overlay on the photo canvas.
//  Holds the layout type, data snapshot, and transform state.
//

import Foundation
import CoreGraphics

struct StickerItem: Identifiable, Equatable {
    let id: UUID
    /// Which visual layout to render.
    var layoutType: StickerLayoutType
    /// Snapshot of run metrics used by the layout view.
    var data: StickerData
    /// Center position in canvas coordinates.
    var position: CGPoint
    /// Scale factor (1 = default size).
    var scale: CGFloat

    init(
        id: UUID = UUID(),
        layoutType: StickerLayoutType,
        data: StickerData,
        position: CGPoint,
        scale: CGFloat = 1
    ) {
        self.id = id
        self.layoutType = layoutType
        self.data = data
        self.position = position
        self.scale = scale
    }
}
