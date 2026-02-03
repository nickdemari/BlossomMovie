//
//  MediaDetailContentView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct MediaDetailContentView: View {
    let mediaItem: MediaItem
    let releaseInfo: String
    let hasTrailer: Bool
    let isDownloaded: Bool
    let youtubeEmbedURL: URL?
    let onPlayTrailerTapped: () -> Void
    let onDownloadTapped: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
            // Title and Rating
            MediaDetailHeaderView(
                mediaItem: mediaItem,
                releaseInfo: releaseInfo
            )

            // Action Buttons
            MediaDetailActionButtonsView(
                hasTrailer: hasTrailer,
                isDownloaded: isDownloaded,
                onPlayTrailerTapped: onPlayTrailerTapped,
                onDownloadTapped: onDownloadTapped
            )

            // Overview
            if let overview = mediaItem.overview, !overview.isEmpty {
                MediaDetailOverviewView(overview: overview)
            }

            // Additional Info
            MediaDetailInfoView(mediaItem: mediaItem)

            // YouTube Video (if available)
            if let youtubeURL = youtubeEmbedURL {
                MediaDetailTrailerView(youtubeURL: youtubeURL)
            }
        }
    }
}

#Preview {
    ScrollView {
        MediaDetailContentView(
            mediaItem: MediaItem.previewItems[0],
            releaseInfo: "2024-01-15 • Rating: 8.5/10",
            hasTrailer: true,
            isDownloaded: false,
            youtubeEmbedURL: nil,
            onPlayTrailerTapped: {},
            onDownloadTapped: {}
        )
        .padding()
    }
}
