//
//  BackgroundSelectionView.swift
//  Stride
//
//  Screen to select a background image: Camera Roll (default), Presets and Backgrounds disabled.
//  Dark theme with themed controls.
//

import SwiftUI

enum BackgroundSourceSegment: String, CaseIterable {
    case cameraRoll = "Camera Roll"
    case presets = "Presets"
    case backgrounds = "Backgrounds"
}

/// Identifiable wrapper to present the editor with a loaded image.
private struct EditorImageWrapper: Identifiable {
    let id = UUID()
    let image: UIImage
}

struct BackgroundSelectionView: View {
    let runItem: RunFeedItem
    var onDismiss: (() -> Void)?

    @State private var selectedSegment: BackgroundSourceSegment = .cameraRoll
    @State private var photoService = PhotoLibraryService()
    @State private var loadingAssetForEditor: PhotoAssetItem?
    @State private var imageForEditor: EditorImageWrapper?

    var body: some View {
        VStack(spacing: 0) {
            segmentPicker
            if selectedSegment == .cameraRoll {
                albumSelector
                cameraRollGrid
            } else {
                disabledPlaceholder
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Select Background")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            await photoService.prepare()
        }
        .onDisappear {
            onDismiss?()
        }
        .fullScreenCover(item: $imageForEditor) { wrapper in
            NavigationStack {
                PhotoEditorView(runItem: runItem, image: wrapper.image) {
                    imageForEditor = nil
                }
            }
        }
        .overlay {
            if loadingAssetForEditor != nil {
                AppColors.overlay
                    .ignoresSafeArea()
                ProgressView("Loading…")
                    .tint(AppColors.accent)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }

    private var segmentPicker: some View {
        Picker("Source", selection: $selectedSegment) {
            ForEach(BackgroundSourceSegment.allCases, id: \.self) { segment in
                Text(segment.rawValue).tag(segment)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
    }

    @ViewBuilder
    private var albumSelector: some View {
        if let selected = photoService.selectedAlbum {
            Menu {
                ForEach(photoService.albums) { album in
                    Button(album.title) {
                        Task { await photoService.selectAlbum(album) }
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xs) {
                    Text(selected.title)
                        .font(AppFont.secondary)
                        .foregroundStyle(AppColors.textPrimary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private var cameraRollGrid: some View {
        if let error = photoService.loadError {
            ContentUnavailableView(
                "Photo Access Needed",
                systemImage: "photo.on.rectangle.angled",
                description: Text(error)
            )
            .foregroundStyle(AppColors.textSecondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2),
                    GridItem(.flexible(), spacing: 2)
                ], spacing: 2) {
                    ForEach(photoService.assets) { item in
                        Button {
                            openEditor(for: item)
                        } label: {
                            PhotoThumbnailCell(assetId: item.id, photoService: photoService)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(2)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var disabledPlaceholder: some View {
        ContentUnavailableView(
            "Coming Soon",
            systemImage: "photo.stack",
            description: Text("Presets and custom backgrounds will be available in a future update.")
        )
        .foregroundStyle(AppColors.textSecondary)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func openEditor(for item: PhotoAssetItem) {
        loadingAssetForEditor = item
        Task {
            guard let img = await photoService.loadFullImage(for: item.asset) else {
                await MainActor.run { loadingAssetForEditor = nil }
                return
            }
            await MainActor.run {
                imageForEditor = EditorImageWrapper(image: img)
                loadingAssetForEditor = nil
            }
        }
    }
}

#Preview {
    NavigationStack {
        BackgroundSelectionView(
            runItem: RunFeedItem(
                id: 1,
                distanceKm: 5.42,
                pacePerKmDisplay: "5:17",
                movingTimeSeconds: 1924,
                dateDisplay: "Jan 15, 2026",
                locationDisplay: "San Francisco, CA",
                polyline: nil
            ),
            onDismiss: nil
        )
    }
}
