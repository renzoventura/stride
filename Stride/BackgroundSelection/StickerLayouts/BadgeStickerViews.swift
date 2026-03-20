//
//  BadgeStickerViews.swift
//  Stride
//
//  Badge-style stickers: rounded, centered compositions with labels.
//  Uses ROUND8-FOUR for a rounded, badge-friendly aesthetic.
//

import SwiftUI

// MARK: - Distance Badge

/// Clean rounded badge with distance as the sole focus.
struct DistanceBadgeSticker: View {
    let data: StickerData

    var body: some View {
        VStack(spacing: 2) {
            Text(data.formattedDistance)
                .font(.custom("ROUND8-FOUR", size: 32))
                .foregroundStyle(.white)
            Text("KM")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(2)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.8), in: .rect(cornerRadius: 18))
    }
}

// MARK: - Long Run Badge

/// Adapts label based on distance: MARATHON, HALF MARATHON, or LONG RUN.
struct LongRunBadgeSticker: View {
    let data: StickerData

    private var label: String {
        if data.isMarathon { return "MARATHON" }
        if data.isHalfMarathon { return "HALF MARATHON" }
        return "LONG RUN"
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(AppColors.accent)
                .tracking(2)

            Text(data.formattedDistance)
                .font(.custom("ROUND8-FOUR", size: 28))
                .foregroundStyle(.white)

            Text("KM")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(2)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background(Color.black.opacity(0.8), in: .rect(cornerRadius: 18))
    }
}

// MARK: - PR Badge

/// Personal Best badge with an orange accent border and PR label.
struct PRBadgeSticker: View {
    let data: StickerData

    var body: some View {
        VStack(spacing: 4) {
            Text("PR")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(AppColors.accent)
                .tracking(3)

            Text(data.formattedDistance)
                .font(.custom("Humane-Bold", size: 38))
                .foregroundStyle(.white)

            Text("KM")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.white.opacity(0.45))
                .tracking(2)

            if let pace = data.paceDisplay {
                Text("\(pace)/km")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.8))
                .overlay {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(AppColors.accent.opacity(0.4), lineWidth: 1)
                }
        }
    }
}
