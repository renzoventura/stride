//
//  ImageOverlayItem.swift
//  Stride
//
//  Model for a UIImage overlay placed on the photo canvas (gallery photo or map snapshot).
//

import Foundation
import CoreGraphics
import UIKit

struct ImageOverlayItem: Identifiable {
    let id: UUID
    var image: UIImage
    /// Optional full-opacity layer drawn on top of `image` (e.g. map polyline over a faded map tile).
    var topImage: UIImage?
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double
    /// Global z-order used to layer items across stickers and image overlays.
    var zOrder: Int

    init(id: UUID = UUID(), image: UIImage, topImage: UIImage? = nil, position: CGPoint, scale: CGFloat = 1, opacity: Double = 1, zOrder: Int = 0) {
        self.id = id
        self.image = image
        self.topImage = topImage
        self.position = position
        self.scale = scale
        self.opacity = opacity
        self.zOrder = zOrder
    }
}
