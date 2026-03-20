//
//  EditorialStickerViews.swift
//  Stride
//
//  Editorial stickers: structured label-above-value hierarchy.
//  Clean, typographic-forward layouts.
//

import SwiftUI

// MARK: - Editorial Full

/// Three labeled metric rows: distance, pace, and time.
struct EditorialFullSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            VStack(alignment: .leading, spacing: 10) {
                metricRow(label: "DISTANCE", value: "\(data.formattedDistance) KM")

                if let pace = data.paceDisplay {
                    metricRow(label: "AVG PACE", value: "\(pace) /KM")
                }

                metricRow(label: "TIME", value: data.timeDisplay)
            }
            .frame(minWidth: 120, alignment: .leading)
        }
    }

    private func metricRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(1.5)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Editorial Duo

/// Two labeled metric rows: distance and pace (or time if no pace).
struct EditorialDuoSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            VStack(alignment: .leading, spacing: 10) {
                metricRow(label: "DISTANCE", value: "\(data.formattedDistance) KM")

                if let pace = data.paceDisplay {
                    metricRow(label: "AVG PACE", value: "\(pace) /KM")
                } else {
                    metricRow(label: "TIME", value: data.timeDisplay)
                }
            }
            .frame(minWidth: 110, alignment: .leading)
        }
    }

    private func metricRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(label)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(1.5)
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Performance Card

/// Two large metrics side-by-side with a divider and total time below.
struct PerformanceCardSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 12) {
            VStack(spacing: 8) {
                HStack(spacing: 20) {
                    metricColumn(value: data.formattedDistance, unit: "KM")
                    if let pace = data.paceDisplay {
                        metricColumn(value: pace, unit: "/KM")
                    }
                }

                Rectangle()
                    .fill(.white.opacity(0.12))
                    .frame(height: 0.5)

                VStack(spacing: 1) {
                    Text(data.timeDisplay)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                    Text("TOTAL TIME")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white.opacity(0.35))
                        .tracking(1.5)
                }
            }
        }
    }

    private func metricColumn(value: String, unit: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(unit)
                .font(.system(size: 8, weight: .bold))
                .foregroundStyle(.white.opacity(0.35))
                .tracking(1)
        }
    }
}
