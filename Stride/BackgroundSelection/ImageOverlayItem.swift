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
    var position: CGPoint
    var scale: CGFloat
    var opacity: Double

    init(id: UUID = UUID(), image: UIImage, position: CGPoint, scale: CGFloat = 1, opacity: Double = 1) {
        self.id = id
        self.image = image
        self.position = position
        self.scale = scale
        self.opacity = opacity
    }
}
