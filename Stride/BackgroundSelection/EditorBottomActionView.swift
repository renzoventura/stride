//
//  EditorBottomActionView.swift
//  Stride
//
//  Layer 3: Fixed bottom control panel. Dark theme with clear interaction states.
//

import SwiftUI

/// Fixed bottom action bar for the photo editor.
struct EditorBottomActionView: View {
    let isSaving: Bool
    let onShare: () -> Void
    let onSave: () -> Void
    let onStory: () -> Void

    static let height: CGFloat = 80

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.divider)
                .frame(height: 1)

            HStack(spacing: AppSpacing.sm) {
                // Story (primary CTA)
                Button(action: onStory) {
                    HStack(spacing: AppSpacing.sm) {
                        InstagramIcon(size: 16)
                        Text("Story")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccentButtonStyle())

                // Save (inverse accent)
                Button(action: onSave) {
                    Label("Save", systemImage: "square.and.arrow.down")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccentOutlineButtonStyle())
                .disabled(isSaving)
                .opacity(isSaving ? 0.5 : 1)

                Spacer()

                // Share (icon-only)
                Button(action: onShare) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 18, weight: .semibold))
                }
                .buttonStyle(GhostButtonStyle())
                .accessibilityLabel("Share")
            }
            .padding(.horizontal, AppSpacing.md)
            .frame(maxHeight: .infinity)
        }
        .frame(height: Self.height)
        .background(AppColors.surfaceElevated)
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

            // Outer rounded rect
            let outerPath = Path(roundedRect: rect.insetBy(dx: s * 0.04, dy: s * 0.04),
                                 cornerRadius: cornerRadius)
            context.stroke(outerPath, with: .foreground, lineWidth: s * 0.09)

            // Center circle
            let circleRadius = s * 0.22
            let center = CGPoint(x: s / 2, y: s / 2)
            let circlePath = Path(ellipseIn: CGRect(
                x: center.x - circleRadius,
                y: center.y - circleRadius,
                width: circleRadius * 2,
                height: circleRadius * 2
            ))
            context.stroke(circlePath, with: .foreground, lineWidth: s * 0.09)

            // Top-right dot
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
