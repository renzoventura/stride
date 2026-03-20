//
//  BigMetricStickerViews.swift
//  Stride
//
//  Big Metric Focus stickers: one dominant number with supporting metrics.
//  Uses Humane-Bold for dramatic, tall hero numbers.
//

import SwiftUI

// MARK: - Big Distance

/// Large distance as the hero metric. Pace and time as supporting line.
struct BigDistanceSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground {
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(data.formattedDistance)
                        .font(.custom("Humane-Bold", size: 52))
                        .foregroundStyle(.white)
                    Text("KM")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                }

                supportingLine
            }
        }
    }

    private var supportingLine: some View {
        Group {
            if let pace = data.paceDisplay {
                Text("\(pace)/km  \u{00B7}  \(data.timeDisplay)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            } else {
                Text(data.timeDisplay)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}

// MARK: - Big Pace

/// Large pace as the hero metric. Distance and time as supporting line.
struct BigPaceSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground {
            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 3) {
                    Text(data.paceDisplay ?? "—")
                        .font(.custom("Humane-Bold", size: 52))
                        .foregroundStyle(.white)
                    Text("/KM")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.45))
                }

                Text("\(data.formattedDistance)km  \u{00B7}  \(data.timeDisplay)")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}

// MARK: - Big Time

/// Large total time as the hero metric. Distance and pace as supporting line.
struct BigTimeSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground {
            VStack(spacing: 4) {
                Text(data.timeDisplay)
                    .font(.custom("Humane-Bold", size: 48))
                    .foregroundStyle(.white)

                Text("TOTAL TIME")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.white.opacity(0.35))
                    .tracking(1.5)

                supportingLine
            }
        }
    }

    private var supportingLine: some View {
        Group {
            if let pace = data.paceDisplay {
                Text("\(data.formattedDistance)km  \u{00B7}  \(pace)/km")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            } else {
                Text("\(data.formattedDistance)km")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(.white.opacity(0.55))
            }
        }
    }
}
