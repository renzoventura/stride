//
//  RunStickerOption.swift
//  Stride
//
//  Generates sticker layout options for a run. Each option maps to a distinct
//  visual composition (StickerLayoutType). Options are filtered based on
//  available data — layouts that require pace won't appear for runs without it.
//

import Foundation

/// A selectable sticker layout option shown in the picker.
struct RunStickerOption: Identifiable, Hashable {
    var id: StickerLayoutType { layoutType }
    let layoutType: StickerLayoutType
    let category: StickerCategory

    var title: String { layoutType.title }
}

extension RunFeedItem {
    /// All sticker layout options available for this run.
    var stickerOptions: [RunStickerOption] {
        let data = stickerData
        return StickerLayoutType.allCases
            .filter { $0.isAvailable(for: data) }
            .map { RunStickerOption(layoutType: $0, category: $0.category) }
    }
}
