//
//  SpecialStickerViews.swift
//  Stride
//
//  Minimal and special-purpose sticker layouts.
//  Location stamp, date run, and clean minimal metric-only stickers.
//

import SwiftUI

// MARK: - Location Stamp

/// Location as the headline in accent, distance and date below.
struct LocationStampSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            VStack(alignment: .leading, spacing: 3) {
                Text(data.locationDisplay?.uppercased() ?? "")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(AppColors.accent)
                    .tracking(1.5)

                Text("\(data.formattedDistance) KM")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.white)

                Text(data.dateDisplay)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }
}

// MARK: - Minimal Distance

/// Ultra-clean: just the distance number with unit. Nothing else.
struct MinimalDistanceSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(data.formattedDistance)
                    .font(.custom("Humane-Bold", size: 44))
                    .foregroundStyle(.white)
                Text("KM")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }
}

// MARK: - Minimal Pace

/// Ultra-clean: just the pace with unit. Nothing else.
struct MinimalPaceSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(data.paceDisplay ?? "—")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text("/KM")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.white.opacity(0.45))
            }
        }
    }
}

// MARK: - Date Run

/// Date as the headline, distance as a supporting line.
struct DateRunSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(data.dateDisplay.uppercased())
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .tracking(0.5)
                Text("\(data.formattedDistance)KM RUN")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}
