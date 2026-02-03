//
//  MediaDetailOverviewView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct MediaDetailOverviewView: View {
    let overview: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            Text("Overview")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(overview)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
    }
}

struct MediaDetailInfoView: View {
    let mediaItem: MediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            Text("Details")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                MediaDetailRow(title: "Popularity", value: String(format: "%.1f", mediaItem.popularity))
                MediaDetailRow(title: "Vote Count", value: "\(mediaItem.voteCount)")
                
                if let language = mediaItem.originalLanguage {
                    MediaDetailRow(title: "Original Language", value: language.uppercased())
                }
            }
        }
    }
}

struct MediaDetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct MediaDetailTrailerView: View {
    let youtubeURL: URL
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            Text("Trailer")
                .font(.headline)
                .foregroundColor(.primary)
            
            WebView(url: youtubeURL)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        MediaDetailOverviewView(overview: "This is a sample overview for a movie or TV show.")
        MediaDetailInfoView(mediaItem: MediaItem.previewItems[0])
    }
    .padding()
}
