//
//  StickerData.swift
//  Stride
//
//  Immutable snapshot of run metrics consumed by all sticker layout views.
//  Decoupled from RunFeedItem so layouts have no dependency on the feed layer.
//

import Foundation

struct StickerData: Equatable, Hashable {
    let distanceKm: Double
    let paceDisplay: String?
    let timeDisplay: String
    let locationDisplay: String?
    let dateDisplay: String

    // MARK: - Computed helpers

    var formattedDistance: String {
        distanceKm.formatted(.number.precision(.fractionLength(1)))
    }

    var isLongRun: Bool { distanceKm >= 15.0 }
    var isHalfMarathon: Bool { distanceKm >= 21.0 && distanceKm < 42.0 }
    var isMarathon: Bool { distanceKm >= 42.0 }
}

// MARK: - RunFeedItem bridge

extension RunFeedItem {
    /// Builds a sticker data snapshot from this run's metrics.
    var stickerData: StickerData {
        let duration = Duration.seconds(movingTimeSeconds)
        let timeStr: String
        if movingTimeSeconds >= 3600 {
            timeStr = duration.formatted(.time(pattern: .hourMinuteSecond))
        } else {
            timeStr = duration.formatted(.time(pattern: .minuteSecond))
        }
        return StickerData(
            distanceKm: distanceKm,
            paceDisplay: pacePerKmDisplay,
            timeDisplay: timeStr,
            locationDisplay: locationDisplay,
            dateDisplay: dateDisplay
        )
    }
}
