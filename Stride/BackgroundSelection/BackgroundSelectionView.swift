//
//  BackgroundSelectionView.swift
//  Stride
//
//  Screen to select a background image: Camera Roll or Map snapshot of the selected run.
//  Dark theme with themed controls.
//

import MapKit
import SwiftUI

enum BackgroundSourceSegment: String, CaseIterable {
    case cameraRoll = "Camera Roll"
    case map = "Map"
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
                MapBackgroundTab(polyline: runItem.polyline) { image in
                    imageForEditor = EditorImageWrapper(image: image)
                }
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

// MARK: - Map background tab

private struct MapBackgroundTab: View {
    let polyline: String?
    let onSelect: (UIImage) -> Void

    @State private var snapshot: UIImage?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let polyline, !polyline.isEmpty {
                if isLoading {
                    VStack {
                        Spacer()
                        ProgressView("Generating map…")
                            .tint(AppColors.accent)
                            .foregroundStyle(AppColors.textSecondary)
                        Spacer()
                    }
                } else if let snapshot {
                    ScrollView {
                        Button {
                            onSelect(snapshot)
                        } label: {
                            Image(uiImage: snapshot)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.md))
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppRadius.md)
                                        .strokeBorder(AppColors.surfaceElevated, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .padding(AppSpacing.md)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Route",
                    systemImage: "map",
                    description: Text("This run doesn't have a recorded route.")
                )
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            guard let polyline, !polyline.isEmpty, snapshot == nil else { return }
            isLoading = true
            snapshot = await makeSnapshot(polyline: polyline)
            isLoading = false
        }
    }

    private func makeSnapshot(polyline: String) async -> UIImage? {
        let coords = PolylineDecoder.decode(polyline)
        guard !coords.isEmpty else { return nil }

        let size = CGSize(width: 1080, height: 1920)
        let region = regionThatFits(coordinates: coords)

        let options = MKMapSnapshotter.Options()
        options.region = region
        options.size = size
        options.scale = 1
        options.mapType = .mutedStandard

        let snapshotter = MKMapSnapshotter(options: options)
        return await withCheckedContinuation { continuation in
            snapshotter.start { snapshot, _ in
                guard let snapshot else {
                    continuation.resume(returning: nil)
                    return
                }
                continuation.resume(returning: drawRoute(on: snapshot, coordinates: coords))
            }
        }
    }

    private func regionThatFits(coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        var minLat = coordinates[0].latitude
        var maxLat = minLat
        var minLng = coordinates[0].longitude
        var maxLng = minLng
        for c in coordinates.dropFirst() {
            minLat = min(minLat, c.latitude)
            maxLat = max(maxLat, c.latitude)
            minLng = min(minLng, c.longitude)
            maxLng = max(maxLng, c.longitude)
        }
        let padding = 0.01
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, padding) * 1.4,
            longitudeDelta: max(maxLng - minLng, padding) * 1.4
        )
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLng + maxLng) / 2
        )
        return MKCoordinateRegion(center: center, span: span)
    }

    private func drawRoute(on snapshot: MKMapSnapshotter.Snapshot, coordinates: [CLLocationCoordinate2D]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: snapshot.image.size)
        return renderer.image { context in
            snapshot.image.draw(at: .zero)
            let rect = CGRect(origin: .zero, size: snapshot.image.size)
            context.cgContext.setFillColor(CGColor(red: 0.1, green: 0.1, blue: 0.12, alpha: 0.4))
            context.cgContext.fill(rect)
            guard coordinates.count >= 2 else { return }
            let points = coordinates.map { snapshot.point(for: $0) }
            context.cgContext.setStrokeColor(CGColor(red: 1, green: 0.45, blue: 0, alpha: 1))
            context.cgContext.setLineWidth(6)
            context.cgContext.setLineCap(.round)
            context.cgContext.setLineJoin(.round)
            context.cgContext.addLines(between: points)
            context.cgContext.strokePath()
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
