//
//  ModernHomeView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct ModernHomeView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var navigationPath = NavigationPath()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView(.vertical) {
                LazyVStack(spacing: AppConstants.Layout.standardPadding) {
                    switch dependencies.homeViewModel.loadingState {
                    case .idle:
                        EmptyView()
                    case .loading:
                        LoadingView()
                    case .loaded:
                        HomeContentView(
                            viewModel: dependencies.homeViewModel,
                            onItemTapped: { item in
                                navigationPath.append(item)
                            },
                            onDownloadTapped: { item in
                                dependencies.createDownloadViewModel()
                                    .addToDownloads(item, context: modelContext)
                            }
                        )
                    case .error(let message):
                        ErrorView(
                            message: message,
                            retryAction: {
                                Task {
                                    await dependencies.homeViewModel.refresh()
                                }
                            }
                        )
                    }
                }
            }
            .refreshable {
                await dependencies.homeViewModel.refresh()
            }
            .navigationTitle(AppConstants.UI.homeTitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: MediaItem.self) { item in
                MediaDetailView(mediaItem: item)
                    .environment(\.dependencies, dependencies)
            }
        }
        .task {
            await dependencies.homeViewModel.loadContent()
        }
    }
}

// MARK: - Home Content View
private struct HomeContentView: View {
    let viewModel: HomeViewModel
    let onItemTapped: (MediaItem) -> Void
    let onDownloadTapped: (MediaItem) -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            // Hero Section
            if let heroItem = viewModel.heroItem {
                HeroView(
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
            MediaSectionView(
                title: AppConstants.Content.trendingMovies,
                items: viewModel.trendingMovies,
                onItemTapped: onItemTapped
            )
            
            MediaSectionView(
                title: AppConstants.Content.trendingTVShows,
                items: viewModel.trendingTVShows,
                onItemTapped: onItemTapped
            )
            
            MediaSectionView(
                title: AppConstants.Content.topRatedMovies,
                items: viewModel.topRatedMovies,
                onItemTapped: onItemTapped
            )
            
            MediaSectionView(
                title: AppConstants.Content.topRatedTVShows,
                items: viewModel.topRatedTVShows,
                onItemTapped: onItemTapped
            )
        }
        .animation(.easeInOut(duration: AppConstants.Animation.defaultDuration), value: viewModel.loadingState)
    }
}

// MARK: - Hero View
private struct HeroView: View {
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
                        ActionButton(
                            title: AppConstants.UI.playButtonText,
                            icon: AppConstants.UI.playIcon,
                            action: onPlayTapped
                        )
                        
                        ActionButton(
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

// MARK: - Media Section View
private struct MediaSectionView: View {
    let title: String
    let items: [MediaItem]
    let onItemTapped: (MediaItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppConstants.Layout.standardPadding) {
                    ForEach(items) { item in
                        MediaPosterView(item: item)
                            .onTapGesture {
                                onItemTapped(item)
                            }
                    }
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
            }
        }
    }
}

#Preview {
    ModernHomeView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}