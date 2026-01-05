//
//  MediaDetailHeroView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct MediaDetailHeroView: View {
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Background Image
                AsyncImage(url: URL(string: mediaItem.fullBackdropURL ?? mediaItem.fullPosterURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }
                }
                
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
                MediaDetailPlayButton(viewModel: viewModel)
            }
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

#Preview {
    MediaDetailHeroView(
        mediaItem: MediaItem.previewItems[0],
        viewModel: nil
    )
    .frame(height: 300)
}