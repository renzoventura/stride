//
//  PhotoLibraryService.swift
//  Stride
//
//  Fetches photo library albums (Recents, Favorites, user albums) and assets for grid display.
//

import Foundation
import Photos
import UIKit

/// Represents an album the user can select (Recents, Favorites, All Albums, or a user album).
struct PhotoAlbum: Identifiable, Equatable {
    let id: String
    let title: String
    /// Nil for "All Albums" (all photos).
    let assetCollection: PHAssetCollection?
}

/// Lightweight representation of a photo asset for grid display. Load thumbnails via PhotoLibraryService.
struct PhotoAssetItem: Identifiable {
    let id: String
    let asset: PHAsset
}

@MainActor
@Observable
final class PhotoLibraryService {
    private(set) var authorizationStatus: PHAuthorizationStatus = .notDetermined
    private(set) var albums: [PhotoAlbum] = []
    private(set) var selectedAlbum: PhotoAlbum?
    private(set) var assets: [PhotoAssetItem] = []
    private(set) var loadError: String?

    private let imageManager = PHCachingImageManager()
    private let thumbnailSize = CGSize(width: 400, height: 400)

    init() {}

    /// Call on appear to request authorization and load albums. Default selection: Recents.
    func prepare() async {
        let status = await requestAuthorization()
        guard status == .authorized || status == .limited else {
            loadError = "Photo library access is required to choose a background."
            return
        }
        loadError = nil
        await loadAlbums()
        if let recents = albums.first(where: { $0.id == "recents" }) {
            await selectAlbum(recents)
        }
    }

    func requestAuthorization() async -> PHAuthorizationStatus {
        var status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        if status == .notDetermined {
            status = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                    continuation.resume(returning: newStatus)
                }
            }
        }
        authorizationStatus = status
        return status
    }

    func loadAlbums() async {
        var result: [PhotoAlbum] = []

        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: nil
        )
        smartAlbums.enumerateObjects { collection, _, _ in
            guard collection.assetCollectionSubtype == .smartAlbumUserLibrary
                || collection.assetCollectionSubtype == .smartAlbumFavorites else { return }
            let title: String
            let id: String
            switch collection.assetCollectionSubtype {
            case .smartAlbumUserLibrary:
                title = "Recents"
                id = "recents"
            case .smartAlbumFavorites:
                title = "Favorites"
                id = "favorites"
            default:
                title = collection.localizedTitle ?? "Album"
                id = collection.localIdentifier
            }
            result.append(PhotoAlbum(id: id, title: title, assetCollection: collection))
        }

        result.append(PhotoAlbum(id: "all", title: "All Albums", assetCollection: nil))

        let userAlbums = PHAssetCollection.fetchTopLevelUserCollections(with: nil)
        var userAlbumList: [PhotoAlbum] = []
        userAlbums.enumerateObjects { collection, _, _ in
            guard let coll = collection as? PHAssetCollection else { return }
            let title = coll.localizedTitle ?? "Album"
            userAlbumList.append(PhotoAlbum(id: coll.localIdentifier, title: title, assetCollection: coll))
        }
        userAlbumList.sort { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        result.append(contentsOf: userAlbumList)

        albums = result
    }

    func selectAlbum(_ album: PhotoAlbum) async {
        selectedAlbum = album
        await loadAssets(for: album)
    }

    private func loadAssets(for album: PhotoAlbum) async {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "addedDate", ascending: false)]
        options.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        let fetchResult: PHFetchResult<PHAsset>
        if let collection = album.assetCollection {
            fetchResult = PHAsset.fetchAssets(in: collection, options: options)
        } else {
            fetchResult = PHAsset.fetchAssets(with: .image, options: options)
        }
        var items: [PhotoAssetItem] = []
        fetchResult.enumerateObjects { asset, _, _ in
            items.append(PhotoAssetItem(id: asset.localIdentifier, asset: asset))
        }
        assets = items
    }

    /// Load thumbnail for a grid cell. Call from the view when the cell appears.
    func loadThumbnail(for assetId: String) async -> UIImage? {
        guard let item = assets.first(where: { $0.id == assetId }) else { return nil }
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            var hasResumed = false
            imageManager.requestImage(
                for: item.asset,
                targetSize: thumbnailSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: image)
            }
        }
    }

    /// Load full-resolution image for editing. Uses a target size to avoid freezing the UI with huge assets.
    func loadFullImage(for asset: PHAsset, targetLongEdge: CGFloat = 2048) async -> UIImage? {
        let pixelWidth = CGFloat(asset.pixelWidth)
        let pixelHeight = CGFloat(asset.pixelHeight)
        let longEdge = max(pixelWidth, pixelHeight)
        let targetSize: CGSize
        if longEdge <= targetLongEdge {
            targetSize = PHImageManagerMaximumSize
        } else {
            let scale = targetLongEdge / longEdge
            targetSize = CGSize(width: pixelWidth * scale, height: pixelHeight * scale)
        }
        return await withCheckedContinuation { continuation in
            let options = PHImageRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true
            options.isSynchronous = false
            var hasResumed = false
            imageManager.requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                guard !hasResumed else { return }
                hasResumed = true
                continuation.resume(returning: image)
            }
        }
    }
}
