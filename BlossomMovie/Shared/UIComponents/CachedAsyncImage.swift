//
//  CachedAsyncImage.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

/// Reusable async image component with consistent placeholder and error handling
struct CachedAsyncImage: View {
    let url: URL?
    let width: CGFloat?
    let height: CGFloat?
    let contentMode: ContentMode
    let cornerRadius: CGFloat

    init(
        url: URL?,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = AppConstants.Layout.cornerRadius
    ) {
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                placeholder
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: width, height: height)
                    .clipped()
            case .failure:
                placeholder
                    .overlay {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundColor(.orange)
                            .font(.caption)
                    }
            @unknown default:
                placeholder
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .overlay {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
            }
    }
}

// MARK: - Convenience Initializers
extension CachedAsyncImage {
    /// Convenience initializer for poster images
    init(posterURL: String?, width: CGFloat = AppConstants.Layout.compactPosterWidth, height: CGFloat = AppConstants.Layout.compactPosterHeight) {
        self.init(
            url: posterURL.flatMap { URL(string: $0) },
            width: width,
            height: height,
            contentMode: .fill
        )
    }

    /// Convenience initializer for backdrop images
    init(backdropURL: String?, width: CGFloat, height: CGFloat) {
        self.init(
            url: backdropURL.flatMap { URL(string: $0) },
            width: width,
            height: height,
            contentMode: .fill
        )
    }
}

#Preview {
    VStack(spacing: 16) {
        CachedAsyncImage(
            posterURL: MediaItem.previewItems[0].fullPosterURL
        )

        CachedAsyncImage(
            backdropURL: MediaItem.previewItems[0].fullBackdropURL,
            width: 300,
            height: 200
        )

        CachedAsyncImage(
            url: URL(string: "invalid-url"),
            width: 150,
            height: 200
        )
    }
    .padding()
}
