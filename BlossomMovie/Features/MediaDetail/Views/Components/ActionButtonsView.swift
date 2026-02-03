//
//  MediaDetailActionButtonsView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct MediaDetailActionButtonsView: View {
    let hasTrailer: Bool
    let isDownloaded: Bool
    let onPlayTrailerTapped: () -> Void
    let onDownloadTapped: () -> Void

    var body: some View {
        HStack(spacing: AppConstants.Layout.standardPadding) {
            if hasTrailer {
                Button {
                    onPlayTrailerTapped()
                } label: {
                    Label("Play Trailer", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }

            Button {
                onDownloadTapped()
            } label: {
                Label(
                    isDownloaded ? "Remove" : "Download",
                    systemImage: isDownloaded ? "trash" : "arrow.down.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

#Preview {
    MediaDetailActionButtonsView(
        hasTrailer: true,
        isDownloaded: false,
        onPlayTrailerTapped: {},
        onDownloadTapped: {}
    )
    .padding()
}
