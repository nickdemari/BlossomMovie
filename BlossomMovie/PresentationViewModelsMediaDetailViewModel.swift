//
//  MediaDetailViewModel.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation

/// Media detail view model
@MainActor
@Observable
final class MediaDetailViewModel {
    
    // MARK: - State
    enum VideoState: Equatable {
        case idle
        case loading
        case loaded(String)
        case error(String)
    }
    
    // MARK: - Properties
    let mediaItem: MediaItem
    private(set) var videoState: VideoState = .idle
    private(set) var videoId: String?
    
    // MARK: - Dependencies
    private let mediaRepository: MediaRepositoryProtocol
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(
        mediaItem: MediaItem,
        mediaRepository: MediaRepositoryProtocol,
        logger: LoggerProtocol
    ) {
        self.mediaItem = mediaItem
        self.mediaRepository = mediaRepository
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func loadTrailer() async {
        guard videoState != .loading else { return }
        
        videoState = .loading
        logger.info("Loading trailer for: \(mediaItem.displayTitle)")
        
        do {
            let id = try await mediaRepository.fetchVideoId(for: "\(mediaItem.displayTitle) trailer")
            videoId = id
            videoState = .loaded(id)
            logger.info("Trailer loaded successfully")
        } catch {
            let errorMessage = "Failed to load trailer: \(error.localizedDescription)"
            videoState = .error(errorMessage)
            logger.error(errorMessage)
        }
    }
    
    // MARK: - Computed Properties
    var isLoadingTrailer: Bool {
        videoState == .loading
    }
    
    var hasTrailer: Bool {
        if case .loaded = videoState {
            return true
        }
        return false
    }
    
    var trailerErrorMessage: String? {
        if case .error(let message) = videoState {
            return message
        }
        return nil
    }
    
    var youtubeEmbedURL: URL? {
        guard let videoId = videoId else { return nil }
        return URL(string: "https://youtube.com/embed/\(videoId)")
    }
    
    var formattedOverview: String {
        return mediaItem.overview ?? "No description available."
    }
    
    var formattedReleaseInfo: String {
        let date = mediaItem.displayDate
        let rating = mediaItem.formattedRating
        return date.isEmpty ? "Rating: \(rating)/10" : "\(date) • Rating: \(rating)/10"
    }
}