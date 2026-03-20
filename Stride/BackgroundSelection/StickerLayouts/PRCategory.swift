//
//  PRCategory.swift
//  Stride
//
//  PR detection logic — separate from UI.
//  Matches a run distance to a known race category within tolerance.
//  Returns nil for non-standard distances.
//

import Foundation

/// Standard race categories for personal records.
enum PRCategory: String, Hashable, CaseIterable {
    case mile = "MILE"
    case fiveK = "5K"
    case tenK = "10K"
    case halfMarathon = "HALF MARATHON"
    case marathon = "MARATHON"

    /// Short display label for compact layouts.
    var shortLabel: String {
        switch self {
        case .mile: "MILE"
        case .fiveK: "5K"
        case .tenK: "10K"
        case .halfMarathon: "HALF"
        case .marathon: "MARATHON"
        }
    }

    /// The canonical distance in kilometers for this race category.
    var canonicalDistanceKm: Double {
        switch self {
        case .mile: 1.609
        case .fiveK: 5.0
        case .tenK: 10.0
        case .halfMarathon: 21.0975
        case .marathon: 42.195
        }
    }

    /// Detects the closest standard race category for a given distance.
    /// Uses a 5% tolerance window.
    /// Returns nil if the distance doesn't match any standard race.
    static func detect(distanceKm: Double) -> PRCategory? {
        let tolerance = 0.05
        for category in allCases {
            let diff = abs(distanceKm - category.canonicalDistanceKm) / category.canonicalDistanceKm
            if diff <= tolerance {
                return category
            }
        }
        return nil
    }
}

extension StickerData {
    /// The detected PR category for this run's distance, if it matches a standard race.
    var prCategory: PRCategory? {
        PRCategory.detect(distanceKm: distanceKm)
    }

    /// Display label for PR stickers: race category name or formatted distance.
    var prCategoryLabel: String {
        prCategory?.rawValue ?? "\(formattedDistance)KM"
    }
}
