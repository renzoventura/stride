//
//  RunCardView.swift
//  Stride
//
//  Single run card: 1:1 map fills the card; distance/pace and date overlaid.
//  Dark theme with subtle data overlay.
//

import SwiftUI

struct RunCardView: View {
    let item: RunFeedItem

    private var distanceText: String {
        item.distanceKm.formatted(.number.precision(.fractionLength(2)))
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AppleMapRouteImageView(polyline: item.polyline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Data overlay
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: AppSpacing.xs) {
                    Text(distanceText)
                        .font(AppFont.cardOverlay)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("km")
                        .font(AppFont.cardDate)
                        .foregroundStyle(AppColors.textSecondary)
                    if let pace = item.pacePerKmDisplay {
                        Text("·")
                            .font(AppFont.cardDate)
                            .foregroundStyle(AppColors.textMuted)
                        Text("\(pace)/km")
                            .font(AppFont.cardDate)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
                Text(item.dateDisplay)
                    .font(AppFont.cardDate)
                    .foregroundStyle(AppColors.textMuted)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.background.opacity(0.75), in: .rect(cornerRadius: AppRadius.sm))
            .padding(AppSpacing.xs)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(.rect(cornerRadius: 0))
    }
}

#Preview {
    RunCardView(
        item: RunFeedItem(
            id: 1,
            distanceKm: 5.42,
            pacePerKmDisplay: "5:17",
            movingTimeSeconds: 1924,
            dateDisplay: "Jan 15, 2024",
            locationDisplay: "San Francisco, CA",
            polyline: nil
        )
    )
    .frame(width: 160, height: 160)
    .background(AppColors.background)
}
