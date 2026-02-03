//
//  MediaDetailHeroView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct MediaDetailHeroView: View {
    let mediaItem: MediaItem
    let hasTrailer: Bool
    let isLoadingTrailer: Bool
    let onPlayTapped: () async -> Void

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Background Image
                CachedAsyncImage(
                    url: URL(string: mediaItem.fullBackdropURL ?? mediaItem.fullPosterURL ?? ""),
                    width: geometry.size.width,
                    height: geometry.size.height,
                    contentMode: .fill,
                    cornerRadius: 0
                )

                // Gradient Overlay
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.8), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )

                // Play Button (if video available)
                MediaDetailPlayButton(
                    hasTrailer: hasTrailer,
                    isLoadingTrailer: isLoadingTrailer,
                    onPlayTapped: onPlayTapped
                )
            }
        }
        .frame(height: AppConstants.Layout.detailHeroHeight)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

#Preview {
    MediaDetailHeroView(
        mediaItem: MediaItem.previewItems[0],
        hasTrailer: true,
        isLoadingTrailer: false,
        onPlayTapped: {}
    )
    .frame(height: 300)
}
