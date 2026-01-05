//
//  UpcomingViewModel.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation

/// Upcoming movies view model
@MainActor
@Observable
final class UpcomingViewModel {
    
    // MARK: - State
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    // MARK: - Properties
    private(set) var loadingState: LoadingState = .idle
    private(set) var upcomingMovies: [MediaItem] = []
    
    // MARK: - Dependencies
    private let mediaRepository: MediaRepositoryProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(mediaRepository: MediaRepositoryProtocol, logger: LoggerProtocol) {
        self.mediaRepository = mediaRepository
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func loadUpcomingMovies() async {
        guard loadingState != .loading else { return }
        
        loadingState = .loading
        logger.info("Loading upcoming movies")
        
        do {
            let movies = try await mediaRepository.fetchUpcoming()
            upcomingMovies = movies
            loadingState = .loaded
            logger.info("Upcoming movies loaded successfully: \(movies.count) movies")
        } catch {
            let errorMessage = "Failed to load upcoming movies: \(error.localizedDescription)"
            loadingState = .error(errorMessage)
            logger.error(errorMessage)
        }
    }
    
    func refresh() async {
        upcomingMovies = []
        loadingState = .idle
        await loadUpcomingMovies()
    }
    
    // MARK: - Computed Properties
    var isLoading: Bool {
        loadingState == .loading
    }
    
    var hasMovies: Bool {
        !upcomingMovies.isEmpty
    }
    
    var errorMessage: String? {
        if case .error(let message) = loadingState {
            return message
        }
        return nil
    }
}