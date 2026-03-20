//
//  StickerPickerView.swift
//  Stride
//
//  Modal sticker selection with rich layout previews organized by category.
//  Each section scrolls horizontally, showing the actual sticker composition
//  rendered with real run data.
//

import SwiftUI

struct StickerPickerView: View {
    let data: StickerData
    let options: [RunStickerOption]
    var onSelect: (RunStickerOption) -> Void
    var onDismiss: () -> Void

    /// Groups options by category, preserving StickerCategory.allCases order.
    private var groupedOptions: [(StickerCategory, [RunStickerOption])] {
        let grouped = Dictionary(grouping: options) { $0.category }
        return StickerCategory.allCases.compactMap { category in
            guard let items = grouped[category], !items.isEmpty else { return nil }
            return (category, items)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            dragIndicator
            titleBar

            ScrollView {
                LazyVStack(alignment: .leading, spacing: AppSpacing.lg) {
                    ForEach(groupedOptions, id: \.0) { category, items in
                        sectionView(category: category, items: items)
                    }
                }
                .padding(.bottom, AppSpacing.xl)
            }
            .scrollIndicators(.hidden)
        }
        .background(AppColors.surfaceElevated)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .presentationBackground(AppColors.surfaceElevated)
    }

    // MARK: - Header

    private var dragIndicator: some View {
        RoundedRectangle(cornerRadius: 2.5)
            .fill(AppColors.textMuted)
            .frame(width: 36, height: 4)
            .padding(.top, AppSpacing.sm)
            .padding(.bottom, AppSpacing.md)
    }

    private var titleBar: some View {
        Text("Add Sticker")
            .font(AppFont.sectionHeader)
            .foregroundStyle(AppColors.textPrimary)
            .padding(.bottom, AppSpacing.md)
    }

    // MARK: - Category section

    private func sectionView(category: StickerCategory, items: [RunStickerOption]) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(category.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(AppColors.textMuted)
                .tracking(1.5)
                .padding(.horizontal, AppSpacing.md)

            ScrollView(.horizontal) {
                HStack(spacing: AppSpacing.sm) {
                    ForEach(items) { option in
                        stickerCell(option: option)
                    }
                }
                .padding(.horizontal, AppSpacing.md)
            }
            .scrollIndicators(.hidden)
        }
    }

    // MARK: - Sticker preview cell

    private func stickerCell(option: RunStickerOption) -> some View {
        Button {
            onSelect(option)
            onDismiss()
        } label: {
            VStack(spacing: AppSpacing.xs) {
                StickerLayoutRouter(layoutType: option.layoutType, data: data)
                    .fixedSize()
                    .scaleEffect(0.85, anchor: .center)

                Text(option.title)
                    .font(AppFont.metadata)
                    .foregroundStyle(AppColors.textMuted)
            }
            .padding(AppSpacing.sm)
            .background(AppColors.card.opacity(0.5), in: .rect(cornerRadius: AppRadius.md))
        }
        .buttonStyle(.plain)
    }
}
