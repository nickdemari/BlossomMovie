//
//  HomeHeroView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct HomeHeroView: View {
    let item: MediaItem
    let onPlayTapped: () -> Void
    let onDownloadTapped: () -> Void
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background Image
                AsyncImage(url: URL(string: item.fullBackdropURL ?? "")) { image in
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
                        .init(color: .clear, location: 0.6),
                        .init(color: .black.opacity(0.8), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Content
                VStack(spacing: AppConstants.Layout.compactPadding) {
                    Text(item.displayTitle)
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    HStack(spacing: AppConstants.Layout.standardPadding) {
                        HomeActionButton(
                            title: AppConstants.UI.playButtonText,
                            icon: AppConstants.UI.playIcon,
                            action: onPlayTapped
                        )
                        
                        HomeActionButton(
                            title: AppConstants.UI.downloadButtonText,
                            icon: AppConstants.UI.downloadIcon,
                            style: .secondary,
                            action: onDownloadTapped
                        )
                    }
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.bottom, AppConstants.Layout.standardPadding)
            }
        }
        .frame(height: 500)
        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier(AccessibilityIdentifiers.Home.heroImage)
    }
}

#Preview {
    HomeHeroView(
        item: MediaItem.previewItems[0],
        onPlayTapped: {},
        onDownloadTapped: {}
    )
    .frame(height: 500)
}