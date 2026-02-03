//
//  HomeViewModel.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation

/// Home view model with modern architecture
@MainActor
@Observable
final class HomeViewModel {
    
    // MARK: - State
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    private(set) var loadingState: LoadingState = .idle
    private(set) var trendingMovies: [MediaItem] = []
    private(set) var trendingTVShows: [MediaItem] = []
    private(set) var topRatedMovies: [MediaItem] = []
    private(set) var topRatedTVShows: [MediaItem] = []
    private(set) var heroItem: MediaItem?
    
    // MARK: - Dependencies
    private let mediaRepository: MediaRepositoryProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(mediaRepository: MediaRepositoryProtocol, logger: LoggerProtocol) {
        self.mediaRepository = mediaRepository
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func loadContent() async {
        guard loadingState != .loading else { return }

        loadingState = .loading
        logger.info("Loading home content")
        
        do {
            // Fetch all content concurrently
            async let trendingMoviesTask = mediaRepository.fetchTrending(mediaType: .movie)
            async let trendingTVTask = mediaRepository.fetchTrending(mediaType: .tv)
            async let topRatedMoviesTask = mediaRepository.fetchTopRated(mediaType: .movie)
            async let topRatedTVTask = mediaRepository.fetchTopRated(mediaType: .tv)
            
            let (trendingMoviesResult, trendingTVResult, topRatedMoviesResult, topRatedTVResult) = try await (
                trendingMoviesTask,
                trendingTVTask,
                topRatedMoviesTask,
                topRatedTVTask
            )
            
            // Update state
            trendingMovies = trendingMoviesResult
            trendingTVShows = trendingTVResult
            topRatedMovies = topRatedMoviesResult
            topRatedTVShows = topRatedTVResult

            // Set hero item (use first item for consistency)
            heroItem = trendingMoviesResult.first ?? MediaItem.previewItems.first
            
            loadingState = .loaded
            logger.info("Home content loaded successfully")
            
        } catch {
            let errorMessage = "Failed to load home content: \(error.localizedDescription)"
            loadingState = .error(errorMessage)
            logger.error(errorMessage)
        }
    }
    
    func refresh() async {
        // Clear current data and reload
        trendingMovies = []
        trendingTVShows = []
        topRatedMovies = []
        topRatedTVShows = []
        heroItem = nil
        loadingState = .idle
        
        await loadContent()
    }
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        loadingState == .loading
    }
    
    var hasContent: Bool {
        !trendingMovies.isEmpty || !trendingTVShows.isEmpty || 
        !topRatedMovies.isEmpty || !topRatedTVShows.isEmpty
    }
    
    var errorMessage: String? {
        if case .error(let message) = loadingState {
            return message
        }
        return nil
    }
}
