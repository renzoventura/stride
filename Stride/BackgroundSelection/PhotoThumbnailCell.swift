//
//  PhotoThumbnailCell.swift
//  Stride
//
//  Single cell in the camera roll grid; loads thumbnail asynchronously.
//

import SwiftUI

struct PhotoThumbnailCell: View {
    let assetId: String
    let photoService: PhotoLibraryService
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Rectangle()
                    .fill(.quaternary)
                    .aspectRatio(3 / 4, contentMode: .fit)
                    .overlay { ProgressView() }
            }
        }
        .task(id: assetId) {
            image = await photoService.loadThumbnail(for: assetId)
        }
    }
}
