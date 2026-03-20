//
//  StickerLayoutRouter.swift
//  Stride
//
//  Routes a StickerLayoutType to its corresponding view.
//  Also provides the shared StickerBackground container used by all layouts.
//

import SwiftUI

/// Renders the appropriate sticker layout view for the given type and data.
struct StickerLayoutRouter: View {
    let layoutType: StickerLayoutType
    let data: StickerData

    var body: some View {
        switch layoutType {
        case .bigDistance: BigDistanceSticker(data: data)
        case .bigPace: BigPaceSticker(data: data)
        case .bigTime: BigTimeSticker(data: data)
        case .paceHero: PaceHeroSticker(data: data)
        case .horizontalBar: HorizontalBarSticker(data: data)
        case .compactDuo: CompactDuoSticker(data: data)
        case .distanceBadge: DistanceBadgeSticker(data: data)
        case .longRunBadge: LongRunBadgeSticker(data: data)
        case .prBadge: PRBadgeSticker(data: data)
        case .editorialFull: EditorialFullSticker(data: data)
        case .editorialDuo: EditorialDuoSticker(data: data)
        case .performanceCard: PerformanceCardSticker(data: data)
        case .prBoldAnnouncement: PRBoldAnnouncementSticker(data: data)
        case .prMedal: PRMedalSticker(data: data)
        case .prMinimalElite: PRMinimalEliteSticker(data: data)
        case .prChampionship: PRChampionshipSticker(data: data)
        case .prHighlightFrame: PRHighlightFrameSticker(data: data)
        case .prCompactSocial: PRCompactSocialSticker(data: data)
        }
    }
}

// MARK: - Shared sticker container

/// Consistent dark background container for sticker layouts.
struct StickerBackground<Content: View>: View {
    let cornerRadius: CGFloat
    @ViewBuilder let content: Content

    init(cornerRadius: CGFloat = 10, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        content
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
    }
}
