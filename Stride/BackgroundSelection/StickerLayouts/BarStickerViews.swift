//
//  BarStickerViews.swift
//  Stride
//
//  Bars & Strips stickers: horizontal, compact metric arrangements.
//  PaceHero uses a divider for visual split. HorizontalBar and CompactDuo
//  are minimal overlay-ready strips.
//

import SwiftUI

// MARK: - Pace Hero

/// Pace dominates with an orange accent divider separating distance and time below.
struct PaceHeroSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground {
            VStack(spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(data.paceDisplay ?? "—")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("/KM")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Rectangle()
                    .fill(AppColors.accent)
                    .frame(height: 1.5)

                HStack {
                    Text("\(data.formattedDistance) KM")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                    Spacer()
                    Text(data.timeDisplay)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.65))
                }
            }
            .frame(minWidth: 140)
        }
    }
}

// MARK: - Horizontal Bar

/// Three metrics arranged in a horizontal strip separated by thin vertical dividers.
struct HorizontalBarSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 8) {
            HStack(spacing: 10) {
                metricText("\(data.formattedDistance)KM")
                barDivider
                metricText("\(data.paceDisplay ?? "—")/km")
                barDivider
                metricText(data.timeDisplay)
            }
        }
    }

    private func metricText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
    }

    private var barDivider: some View {
        Rectangle()
            .fill(.white.opacity(0.2))
            .frame(width: 1, height: 14)
    }
}

// MARK: - Compact Duo

/// Minimal two-metric strip: distance and pace separated by a centered dot.
struct CompactDuoSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 8) {
            HStack(spacing: 6) {
                Text("\(data.formattedDistance)KM")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
                Text("\u{00B7}")
                    .foregroundStyle(.white.opacity(0.35))
                Text("\(data.paceDisplay ?? "—")/km")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
}
