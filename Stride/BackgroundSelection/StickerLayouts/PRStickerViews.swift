//
//  PRStickerViews.swift
//  Stride
//
//  Six visually distinct PR celebration sticker layouts.
//  Each celebrates the achievement — no comparisons, no deltas.
//  Uses orange accent intentionally for celebration moments.
//

import SwiftUI

// MARK: - 1. Bold Announcement

/// Large "NEW PR" with dominant time and race category. Dramatic and confident.
struct PRBoldAnnouncementSticker: View {
    let data: StickerData

    var body: some View {
        VStack(spacing: 6) {
            Text("NEW PR")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(AppColors.accent)
                .tracking(4)

            Text(data.timeDisplay)
                .font(.custom("Humane-Bold", size: 56))
                .foregroundStyle(.white)

            Text(data.prCategoryLabel)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(.white.opacity(0.7))

            if let pace = data.paceDisplay {
                Text("\(pace)/km  \u{00B7}  \(data.dateDisplay)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            } else {
                Text(data.dateDisplay)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.85), in: .rect(cornerRadius: 12))
    }
}

// MARK: - 2. Medal / Badge

/// Double-border badge that feels like earning a medal. Concentric rounded rects.
struct PRMedalSticker: View {
    let data: StickerData

    var body: some View {
        VStack(spacing: 6) {
            Text("PR")
                .font(.system(size: 14, weight: .black))
                .foregroundStyle(AppColors.accent)
                .tracking(4)

            Text(data.timeDisplay)
                .font(.custom("Humane-Bold", size: 40))
                .foregroundStyle(.white)

            Text(data.prCategoryLabel)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.5))
                .tracking(2)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background {
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.black.opacity(0.85))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(AppColors.accent.opacity(0.5), lineWidth: 1.5)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(AppColors.accent.opacity(0.2), lineWidth: 1)
                .padding(-4)
        }
    }
}

// MARK: - 3. Minimal Elite

/// Understated premium: subtle PR label, big time, clean supporting info.
struct PRMinimalEliteSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            HStack(alignment: .top, spacing: 10) {
                // Small accent PR tag
                Text("PR")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(AppColors.accent)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(AppColors.accent.opacity(0.15), in: .rect(cornerRadius: 4))

                VStack(alignment: .leading, spacing: 2) {
                    Text(data.timeDisplay)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    HStack(spacing: 4) {
                        Text(data.prCategoryLabel)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.55))
                        if let pace = data.paceDisplay {
                            Text("\u{00B7}")
                                .foregroundStyle(.white.opacity(0.3))
                            Text("\(pace)/km")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.white.opacity(0.45))
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 4. Championship

/// Full official feel: "PERSONAL BEST" spelled out, strong hierarchy.
struct PRChampionshipSticker: View {
    let data: StickerData

    var body: some View {
        VStack(spacing: 8) {
            Text("PERSONAL BEST")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(AppColors.accent)
                .tracking(3)

            Rectangle()
                .fill(AppColors.accent)
                .frame(width: 40, height: 1.5)

            Text(data.prCategoryLabel)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)

            Text(data.timeDisplay)
                .font(.custom("Humane-Bold", size: 48))
                .foregroundStyle(.white)

            if let pace = data.paceDisplay {
                Text("\(pace) /KM")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text(data.dateDisplay)
                .font(.system(size: 9, weight: .medium))
                .foregroundStyle(.white.opacity(0.35))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 18)
        .background(Color.black.opacity(0.85), in: .rect(cornerRadius: 12))
    }
}

// MARK: - 5. Highlight Frame

/// Accent-bordered frame with glow effect. Time centered as the spotlight.
struct PRHighlightFrameSticker: View {
    let data: StickerData

    var body: some View {
        VStack(spacing: 6) {
            Text(data.timeDisplay)
                .font(.custom("Humane-Bold", size: 44))
                .foregroundStyle(.white)

            HStack(spacing: 6) {
                Text(data.prCategoryLabel)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.7))
                Text("PR")
                    .font(.system(size: 9, weight: .black))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(AppColors.accent, in: .rect(cornerRadius: 3))
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 16)
        .background(Color.black.opacity(0.85), in: .rect(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.accent, lineWidth: 2)
        }
        .shadow(color: AppColors.accent.opacity(0.3), radius: 12, x: 0, y: 0)
    }
}

// MARK: - 6. Compact Social

/// Small horizontal pill designed for stacking. Quick PR tag + metric.
struct PRCompactSocialSticker: View {
    let data: StickerData

    var body: some View {
        HStack(spacing: 8) {
            Text("PR")
                .font(.system(size: 10, weight: .black))
                .foregroundStyle(.black)
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(AppColors.accent, in: .rect(cornerRadius: 4))

            Text(data.prCategoryLabel)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)

            Rectangle()
                .fill(.white.opacity(0.2))
                .frame(width: 1, height: 14)

            Text(data.timeDisplay)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.black.opacity(0.85), in: .capsule)
    }
}
