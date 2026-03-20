//
//  EditorOverlayButtons.swift
//  Stride
//
//  Layer 4: Floating overlay buttons. Dark glass circles.
//

import SwiftUI

/// Floating buttons rendered as an overlay above the canvas and bottom bar.
struct EditorOverlayButtons: View {
    let bottomBarHeight: CGFloat
    let onClose: () -> Void
    let onAddSticker: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .allowsHitTesting(false)

            // Close button: top-leading
            closeButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .safeAreaPadding(.top)
                .padding(.leading, AppSpacing.md)

            // Add sticker button: bottom-center, above bottom bar
            addStickerButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, bottomBarHeight + AppSpacing.md)
        }
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
        }
        .buttonStyle(FloatingCircleButtonStyle(size: 40))
        .accessibilityLabel("Close")
    }

    private var addStickerButton: some View {
        Button(action: onAddSticker) {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .bold))
        }
        .buttonStyle(FloatingCircleButtonStyle(size: 52))
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        .accessibilityLabel("Add sticker")
    }
}
