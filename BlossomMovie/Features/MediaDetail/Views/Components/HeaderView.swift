//
//  MediaDetailHeaderView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct MediaDetailHeaderView: View {
    let mediaItem: MediaItem
    let releaseInfo: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            Text(mediaItem.displayTitle)
                .font(.title.bold())
                .foregroundColor(.primary)

            Text(releaseInfo)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Rating
            HStack {
                HStack(spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(index < Int(mediaItem.voteAverage / 2) ? .yellow : .gray.opacity(0.3))
                    }
                }
                
                Text("\(mediaItem.formattedRating)/10")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Media Type Badge
                Text(mediaItem.type?.displayName ?? "")
                    .font(.caption.weight(.medium))
                    .padding(.horizontal, AppConstants.Layout.compactPadding)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
                    .foregroundColor(.blue)
            }
        }
    }
}

#Preview {
    MediaDetailHeaderView(
        mediaItem: MediaItem.previewItems[0],
        releaseInfo: "2024-01-15 • Rating: 8.5/10"
    )
    .padding()
}
