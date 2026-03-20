//
//  AsymmetricStickerViews.swift
//  Stride
//
//  Asymmetric and composition stickers: one dominant side with supporting data stacked opposite.
//  Also includes the split highlight with its signature orange accent bar.
//

import SwiftUI

// MARK: - Asymmetric Left

/// Big distance on the left, supporting metrics stacked on the right.
struct AsymmetricLeftSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            HStack(alignment: .center, spacing: 12) {
                VStack(spacing: 0) {
                    Text(data.formattedDistance)
                        .font(.custom("Humane-Bold", size: 48))
                        .foregroundStyle(.white)
                    Text("KM")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1.5)
                }

                Rectangle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 0.5, height: 42)

                VStack(alignment: .leading, spacing: 4) {
                    if let pace = data.paceDisplay {
                        Text("\(pace)/km")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Text(data.timeDisplay)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                    Text(data.dateDisplay)
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.white.opacity(0.35))
                }
            }
        }
    }
}

// MARK: - Asymmetric Right

/// Supporting metrics stacked on the left, big distance on the right.
struct AsymmetricRightSticker: View {
    let data: StickerData

    var body: some View {
        StickerBackground(cornerRadius: 10) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .trailing, spacing: 4) {
                    if let pace = data.paceDisplay {
                        Text("\(pace)/km")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                    Text(data.timeDisplay)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.75))
                }

                Rectangle()
                    .fill(.white.opacity(0.12))
                    .frame(width: 0.5, height: 42)

                VStack(spacing: 0) {
                    Text(data.formattedDistance)
                        .font(.custom("Humane-Bold", size: 48))
                        .foregroundStyle(.white)
                    Text("KM")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white.opacity(0.4))
                        .tracking(1.5)
                }
            }
        }
    }
}

// MARK: - Split Highlight

/// Orange accent bar on the left edge with pace, distance, and time stacked.
struct SplitHighlightSticker: View {
    let data: StickerData

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.accent)
                .frame(width: 3)

            VStack(alignment: .leading, spacing: 3) {
                if let pace = data.paceDisplay {
                    HStack(alignment: .firstTextBaseline, spacing: 3) {
                        Text(pace)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundStyle(.white)
                        Text("/KM")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.45))
                    }
                }

                Text("\(data.formattedDistance) KM")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.65))

                Text(data.timeDisplay)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white.opacity(0.45))
            }
            .padding(.leading, 10)
            .padding(.trailing, 14)
            .padding(.vertical, 10)
        }
        .background(Color.black.opacity(0.8), in: .rect(cornerRadius: 10))
    }
}
