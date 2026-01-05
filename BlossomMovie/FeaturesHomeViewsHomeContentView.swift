//
//  HomeContentView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct HomeContentView: View {
    let viewModel: HomeViewModel
    let onItemTapped: (MediaItem) -> Void
    let onDownloadTapped: (MediaItem) -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            // Hero Section
            if let heroItem = viewModel.heroItem {
                HomeHeroView(
                    item: heroItem,
                    onPlayTapped: { onItemTapped(heroItem) },
                    onDownloadTapped: { onDownloadTapped(heroItem) }
                )
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.8)),
                    removal: .opacity
                ))
            }
            
            // Content Sections
            HomeMediaSectionView(
                title: AppConstants.Content.trendingMovies,
                items: viewModel.trendingMovies,
                onItemTapped: onItemTapped
            )
            
            HomeMediaSectionView(
                title: AppConstants.Content.trendingTVShows,
                items: viewModel.trendingTVShows,
                onItemTapped: onItemTapped
            )
            
            HomeMediaSectionView(
                title: AppConstants.Content.topRatedMovies,
                items: viewModel.topRatedMovies,
                onItemTapped: onItemTapped
            )
            
            HomeMediaSectionView(
                title: AppConstants.Content.topRatedTVShows,
                items: viewModel.topRatedTVShows,
                onItemTapped: onItemTapped
            )
        }
        .animation(.easeInOut(duration: AppConstants.Animation.defaultDuration), value: viewModel.loadingState)
    }
}

#Preview {
    ScrollView {
        HomeContentView(
            viewModel: DependencyContainer.shared.homeViewModel,
            onItemTapped: { _ in },
            onDownloadTapped: { _ in }
        )
    }
    .injectDependencies()
}