//
//  MediaPosterView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct MediaPosterView: View {
    let item: MediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            AsyncImage(url: URL(string: item.fullPosterURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: AppConstants.Layout.compactPosterWidth,
                        height: AppConstants.Layout.compactPosterHeight
                    )
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(
                        width: AppConstants.Layout.compactPosterWidth,
                        height: AppConstants.Layout.compactPosterHeight
                    )
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            .shadow(color: .black.opacity(0.2), radius: AppConstants.Layout.shadowRadius)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    
                    Text(item.formattedRating)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: AppConstants.Layout.compactPosterWidth, alignment: .leading)
        }
    }
}

#Preview {
    HStack {
        ForEach(MediaItem.previewItems) { item in
            MediaPosterView(item: item)
        }
    }
    .padding()
}