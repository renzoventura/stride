//
//  StickerLayoutType.swift
//  Stride
//
//  Enumerates all sticker layout styles. Each type maps to a distinct visual composition.
//  Adding a new layout: add a case here, implement the view, register in the router.
//

import Foundation

/// Category for grouping sticker layouts in the picker.
enum StickerCategory: String, CaseIterable {
    case bigMetric = "Big Metric"
    case bars = "Bars & Strips"
    case badges = "Badges"
    case editorial = "Editorial"
    case prCelebration = "PR Celebration"
}

/// All available sticker layout types.
enum StickerLayoutType: String, CaseIterable, Hashable, Identifiable {
    var id: String { rawValue }

    // Big Metric Focus
    case bigDistance
    case bigPace
    case bigTime

    // Bars & Strips
    case paceHero
    case horizontalBar
    case compactDuo

    // Badges
    case distanceBadge
    case longRunBadge
    case prBadge

    // Editorial
    case editorialFull
    case editorialDuo
    case performanceCard

    // PR Celebration
    case prBoldAnnouncement
    case prMedal
    case prMinimalElite
    case prChampionship
    case prHighlightFrame
    case prCompactSocial

    var title: String {
        switch self {
        case .bigDistance: "Big Distance"
        case .bigPace: "Big Pace"
        case .bigTime: "Big Time"
        case .paceHero: "Pace Hero"
        case .horizontalBar: "Performance Bar"
        case .compactDuo: "Compact Duo"
        case .distanceBadge: "Distance Badge"
        case .longRunBadge: "Long Run"
        case .prBadge: "Personal Best"
        case .editorialFull: "Full Stats"
        case .editorialDuo: "Duo Stats"
        case .performanceCard: "Performance Card"
        case .prBoldAnnouncement: "PR Announcement"
        case .prMedal: "PR Medal"
        case .prMinimalElite: "PR Elite"
        case .prChampionship: "PR Championship"
        case .prHighlightFrame: "PR Highlight"
        case .prCompactSocial: "PR Compact"
        }
    }

    var category: StickerCategory {
        switch self {
        case .bigDistance, .bigPace, .bigTime: .bigMetric
        case .paceHero, .horizontalBar, .compactDuo: .bars
        case .distanceBadge, .longRunBadge, .prBadge: .badges
        case .editorialFull, .editorialDuo, .performanceCard: .editorial
        case .prBoldAnnouncement, .prMedal, .prMinimalElite,
             .prChampionship, .prHighlightFrame, .prCompactSocial: .prCelebration
        }
    }

    /// Whether this layout is a PR celebration sticker.
    var isPR: Bool { category == .prCelebration }

    /// Whether this layout requires specific data to be present.
    func isAvailable(for data: StickerData) -> Bool {
        switch self {
        case .bigPace, .paceHero, .compactDuo:
            return data.paceDisplay != nil
        case .horizontalBar, .performanceCard, .editorialFull:
            return data.paceDisplay != nil
        case .longRunBadge:
            return data.isLongRun
        // PR stickers are always available — user decides when it's a PR
        default:
            return true
        }
    }
}
