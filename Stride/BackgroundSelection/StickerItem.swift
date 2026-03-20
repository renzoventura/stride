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
    var layoutType: StickerLayoutType
    var data: StickerData
    var position: CGPoint
    var scale: CGFloat
    /// Global z-order used to layer items across stickers and image overlays.
    var zOrder: Int

    init(
        id: UUID = UUID(),
        layoutType: StickerLayoutType,
        data: StickerData,
        position: CGPoint,
        scale: CGFloat = 1,
        zOrder: Int = 0
    ) {
        self.id = id
        self.layoutType = layoutType
        self.data = data
        self.position = position
        self.scale = scale
        self.zOrder = zOrder
    }
}
