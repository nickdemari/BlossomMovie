//
//  AppConstants.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation

/// Application constants
enum AppConstants {
    
    // MARK: - App Information
    enum App {
        static let name = "Blossom Movie"
        static let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        static let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    // MARK: - UI Constants
    enum UI {
        // Tab Items
        static let homeTitle = "Home"
        static let upcomingTitle = "Upcoming"
        static let searchTitle = "Search"
        static let downloadsTitle = "Downloads"
        
        // Icons
        static let homeIcon = "house"
        static let upcomingIcon = "calendar"
        static let searchIcon = "magnifyingglass"
        static let downloadsIcon = "arrow.down.circle"
        static let movieIcon = "film"
        static let tvIcon = "tv"
        static let playIcon = "play.circle"
        static let downloadIcon = "arrow.down.circle"
        static let favoriteIcon = "heart"
        static let favoriteFillIcon = "heart.fill"
        
        // Buttons
        static let playButtonText = "Play"
        static let downloadButtonText = "Download"
        static let retryButtonText = "Retry"
        static let refreshButtonText = "Refresh"
        
        // Messages
        static let noResultsMessage = "No results found"
        static let noDownloadsMessage = "No downloaded items"
        static let loadingMessage = "Loading..."
        static let errorMessage = "Something went wrong"
    }
    
    // MARK: - Content Categories
    enum Content {
        static let trendingMovies = "Trending Movies"
        static let trendingTVShows = "Trending TV Shows"
        static let topRatedMovies = "Top Rated Movies"
        static let topRatedTVShows = "Top Rated TV Shows"
        static let upcomingMovies = "Upcoming Movies"
    }
    
    // MARK: - Search
    enum Search {
        static let moviePlaceholder = "Search movies..."
        static let tvPlaceholder = "Search TV shows..."
        static let movieSearchTitle = "Movie Search"
        static let tvSearchTitle = "TV Search"
    }
    
    // MARK: - Layout
    enum Layout {
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 8
        static let standardPadding: CGFloat = 16
        static let compactPadding: CGFloat = 8

        // Poster dimensions
        static let posterAspectRatio: CGFloat = 2/3
        static let compactPosterWidth: CGFloat = 120
        static let compactPosterHeight: CGFloat = 180

        // Grid
        static let gridColumns = 3
        static let gridSpacing: CGFloat = 16

        // MARK: - Image Heights
        static let homeHeroHeight: CGFloat = 500
        static let detailHeroHeight: CGFloat = 300
        static let searchCardHeight: CGFloat = 200
        static let trailerHeight: CGFloat = 200

        // MARK: - Component Dimensions
        static let playButtonSize: CGFloat = 60
        static let actionButtonHeight: CGFloat = 50
        static let itemRowHeight: CGFloat = 120
        static let infoViewMaxWidth: CGFloat = 600

        // MARK: - Cache Configuration
        static let maxCacheSize: Int = 100
    }
    
    // MARK: - Animation
    enum Animation {
        static let defaultDuration: Double = 0.3
        static let springDuration: Double = 0.5
        static let delayIncrement: Double = 0.1
    }
    
    // MARK: - Test Data URLs (for previews)
    enum TestURLs {
        static let samplePoster1 = "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"
        static let samplePoster2 = "https://image.tmdb.org/t/p/w500/ggFHVNu6YYI5L9pCfOacjizRGt.jpg"
        static let samplePoster3 = "https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg"
    }
}

/// Accessibility identifiers for UI testing
enum AccessibilityIdentifiers {
    enum Tabs {
        static let homeTab = "home_tab"
        static let upcomingTab = "upcoming_tab"
        static let searchTab = "search_tab"
        static let downloadsTab = "downloads_tab"
    }
    
    enum Home {
        static let heroImage = "hero_image"
        static let playButton = "play_button"
        static let downloadButton = "download_button"
        static let trendingSection = "trending_section"
        static let topRatedSection = "top_rated_section"
    }
    
    enum Search {
        static let searchBar = "search_bar"
        static let mediaTypeToggle = "media_type_toggle"
        static let resultsGrid = "results_grid"
        static let noResultsView = "no_results_view"
    }
    
    enum Downloads {
        static let downloadsList = "downloads_list"
        static let emptyDownloads = "empty_downloads"
        static let deleteButton = "delete_button"
    }
}
