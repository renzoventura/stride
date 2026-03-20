//
//  AppTheme.swift
//  Stride
//
//  Centralized design system: colors, typography, spacing, and reusable view modifiers.
//  All views reference this single source of truth for visual consistency.
//
//  Supports future light mode by swapping the palette here.
//

import SwiftUI

// MARK: - Color Palette

enum AppColors {
    // Backgrounds
    static let background = Color(red: 0.09, green: 0.09, blue: 0.10)      // Deep charcoal
    static let surfaceElevated = Color(red: 0.13, green: 0.13, blue: 0.14)  // Slightly lighter surface
    static let card = Color(red: 0.15, green: 0.15, blue: 0.16)             // Card background

    // Text
    static let textPrimary = Color(red: 0.93, green: 0.93, blue: 0.93)      // Off-white
    static let textSecondary = Color(red: 0.55, green: 0.55, blue: 0.56)    // Muted gray
    static let textMuted = Color(red: 0.40, green: 0.40, blue: 0.41)        // Metadata

    // Accent
    static let accent = Color(red: 1.0, green: 0.45, blue: 0.10)            // Strong modern orange
    static let accentSubtle = Color(red: 1.0, green: 0.45, blue: 0.10).opacity(0.15)

    // Utility
    static let divider = Color.white.opacity(0.06)
    static let overlay = Color.black.opacity(0.5)
    static let error = Color(red: 0.95, green: 0.30, blue: 0.30)
}

// MARK: - Typography

enum AppFont {
    /// Large metric numbers (e.g. "5.42 km")
    static let metricLarge = Font.system(size: 28, weight: .bold, design: .rounded)
    /// Medium metric (e.g. pace display in cards)
    static let metricMedium = Font.system(size: 20, weight: .semibold, design: .rounded)
    /// Section headers
    static let sectionHeader = Font.system(size: 15, weight: .semibold)
    /// Body text
    static let body = Font.system(size: 15, weight: .regular)
    /// Secondary labels
    static let secondary = Font.system(size: 13, weight: .medium)
    /// Metadata / small text
    static let metadata = Font.system(size: 11, weight: .medium)
    /// Card overlay tiny text
    static let cardOverlay = Font.system(size: 9, weight: .semibold)
    /// Card overlay date
    static let cardDate = Font.system(size: 7, weight: .medium)
    /// Button label
    static let button = Font.system(size: 15, weight: .semibold)
}

// MARK: - Spacing

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius

enum AppRadius {
    static let sm: CGFloat = 6
    static let md: CGFloat = 10
    static let lg: CGFloat = 14
    static let card: CGFloat = 12
}

// MARK: - Reusable View Modifiers

/// Card-style container with themed background and corner radius.
struct ThemedCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(AppColors.card)
            .clipShape(.rect(cornerRadius: AppRadius.card))
    }
}

extension View {
    func themedCard() -> some View {
        modifier(ThemedCardModifier())
    }
}

/// Primary CTA button style with orange accent.
struct AccentButtonStyle: ButtonStyle {
    let isEnabled: Bool

    init(isEnabled: Bool = true) {
        self.isEnabled = isEnabled
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .foregroundStyle(isEnabled ? .white : AppColors.textMuted)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm + 4)
            .background(
                isEnabled
                    ? (configuration.isPressed ? AppColors.accent.opacity(0.8) : AppColors.accent)
                    : AppColors.surfaceElevated,
                in: .rect(cornerRadius: AppRadius.md)
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

/// Outlined accent button style (inverse of AccentButtonStyle).
struct AccentOutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .foregroundStyle(configuration.isPressed ? AppColors.accent.opacity(0.7) : AppColors.accent)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm + 4)
            .background(
                configuration.isPressed ? AppColors.accent.opacity(0.1) : Color.clear,
                in: .rect(cornerRadius: AppRadius.md)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(configuration.isPressed ? AppColors.accent.opacity(0.5) : AppColors.accent, lineWidth: 1.5)
            }
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
    }
}

/// Secondary ghost button style.
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFont.button)
            .foregroundStyle(configuration.isPressed ? AppColors.textMuted : AppColors.textSecondary)
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm + 4)
            .background(
                configuration.isPressed ? AppColors.surfaceElevated : Color.clear,
                in: .rect(cornerRadius: AppRadius.md)
            )
    }
}

/// Floating circular icon button (glass effect on dark).
struct FloatingCircleButtonStyle: ButtonStyle {
    let size: CGFloat

    init(size: CGFloat = 44) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(AppColors.textPrimary)
            .frame(width: size, height: size)
            .background(AppColors.surfaceElevated.opacity(0.85), in: .circle)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
