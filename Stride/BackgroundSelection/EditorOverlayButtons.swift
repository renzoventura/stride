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
    let isDraggingSticker: Bool
    let onClose: () -> Void
    let onAddSticker: () -> Void
    let onOpenGallery: () -> Void
    let onAddMap4x5: () -> Void
    let onAddMap1x1: () -> Void

    var body: some View {
        ZStack {
            Color.clear
                .allowsHitTesting(false)

            // Close button: top-leading
            closeButton
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .safeAreaPadding(.top)
                .padding(.leading, AppSpacing.md)

            // Add / trash button: bottom-center, above bottom bar
            actionButton
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

    @ViewBuilder
    private var actionButton: some View {
        if isDraggingSticker {
            Button(action: {}) {
                Image(systemName: "trash")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(AppColors.accent)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(FloatingCircleButtonStyle(size: 52))
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .accessibilityLabel("Drag here to delete")
            .transition(.identity)
        } else {
            Menu {
                Button("Stickers", systemImage: "sparkles") {
                    onAddSticker()
                }
                Button("Gallery", systemImage: "photo.on.rectangle") {
                    onOpenGallery()
                }
                Menu {
                    Button("4:5", systemImage: "rectangle.portrait") {
                        onAddMap4x5()
                    }
                    Button("1:1", systemImage: "square") {
                        onAddMap1x1()
                    }
                } label: {
                    Label("Maps", systemImage: "map")
                }
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .frame(width: 52, height: 52)
                    .background(AppColors.surfaceElevated.opacity(0.85), in: .circle)
            }
            .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
            .accessibilityLabel("Add to canvas")
            .transition(.identity)
        }
    }
}

/// Minimal Instagram glyph drawn in SwiftUI.
struct InstagramIcon: View {
    let size: CGFloat

    var body: some View {
        Canvas { context, canvasSize in
            let s = canvasSize.width
            let rect = CGRect(origin: .zero, size: canvasSize)
            let cornerRadius = s * 0.28

            let outerPath = Path(roundedRect: rect.insetBy(dx: s * 0.04, dy: s * 0.04),
                                 cornerRadius: cornerRadius)
            context.stroke(outerPath, with: .foreground, lineWidth: s * 0.09)

            let circleRadius = s * 0.22
            let center = CGPoint(x: s / 2, y: s / 2)
            let circlePath = Path(ellipseIn: CGRect(
                x: center.x - circleRadius,
                y: center.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            ))
            context.stroke(circlePath, with: .foreground, lineWidth: s * 0.09)

            let dotRadius = s * 0.06
            let dotCenter = CGPoint(x: s * 0.74, y: s * 0.26)
            let dotPath = Path(ellipseIn: CGRect(
                x: dotCenter.x - dotRadius,
                y: dotCenter.y - dotRadius,
                width: dotRadius * 2,
                height: dotRadius * 2
            ))
            context.fill(dotPath, with: .foreground)
        }
        .frame(width: size, height: size)
    }
}
