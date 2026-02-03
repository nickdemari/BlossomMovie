//
//  MediaRepository.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation

/// Repository protocol for media data access
protocol MediaRepositoryProtocol {
    func fetchTrending(mediaType: MediaType) async throws -> [MediaItem]
    func fetchTopRated(mediaType: MediaType) async throws -> [MediaItem]
    func fetchUpcoming() async throws -> [MediaItem]
    func search(query: String, mediaType: MediaType) async throws -> [MediaItem]
    func fetchVideoId(for title: String) async throws -> String
}

/// Implementation of media repository
final class MediaRepository: MediaRepositoryProtocol {
    
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    private let configurationManager: ConfigurationManager
    private let cacheService: CacheServiceProtocol
    
    // MARK: - Initialization
    init(
        networkService: NetworkServiceProtocol,
        configurationManager: ConfigurationManager,
        cacheService: CacheServiceProtocol
    ) {
        self.networkService = networkService
        self.configurationManager = configurationManager
        self.cacheService = cacheService
    }
    
    // MARK: - MediaRepositoryProtocol Implementation
    func fetchTrending(mediaType: MediaType) async throws -> [MediaItem] {
        let cacheKey = "trending_\(mediaType.rawValue)"
        
        // Check cache first
        if let cachedItems: [MediaItem] = await cacheService.get(key: cacheKey) {
            return cachedItems
        }
        
        // Fetch from network
        let endpoint = TMDBEndpoint.trending(mediaType: mediaType)
        let response: TMDBResponse<MediaItem> = try await networkService.request(endpoint)
        
        // Cache the result
        await cacheService.set(key: cacheKey, value: response.results)
        
        return response.results
    }
    
    func fetchTopRated(mediaType: MediaType) async throws -> [MediaItem] {
        let cacheKey = "top_rated_\(mediaType.rawValue)"
        
        if let cachedItems: [MediaItem] = await cacheService.get(key: cacheKey) {
            return cachedItems
        }
        
        let endpoint = TMDBEndpoint.topRated(mediaType: mediaType)
        let response: TMDBResponse<MediaItem> = try await networkService.request(endpoint)
        
        await cacheService.set(key: cacheKey, value: response.results)
        
        return response.results
    }
    
    func fetchUpcoming() async throws -> [MediaItem] {
        let cacheKey = "upcoming_movies"
        
        if let cachedItems: [MediaItem] = await cacheService.get(key: cacheKey) {
            return cachedItems
        }
        
        let endpoint = TMDBEndpoint.upcoming
        let response: TMDBResponse<MediaItem> = try await networkService.request(endpoint)
        
        await cacheService.set(key: cacheKey, value: response.results)
        
        return response.results
    }
    
    func search(query: String, mediaType: MediaType) async throws -> [MediaItem] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return []
        }

        // Check cache first
        let cacheKey = "search_\(mediaType.rawValue)_\(query.lowercased())"
        if let cachedItems: [MediaItem] = await cacheService.get(key: cacheKey) {
            return cachedItems
        }

        let endpoint = TMDBEndpoint.search(query: query, mediaType: mediaType)
        let response: TMDBResponse<MediaItem> = try await networkService.request(endpoint)

        // Cache the result
        await cacheService.set(key: cacheKey, value: response.results)

        return response.results
    }
    
    func fetchVideoId(for title: String) async throws -> String {
        let cacheKey = "video_id_\(title)"
        
        if let cachedVideoId: String = await cacheService.get(key: cacheKey) {
            return cachedVideoId
        }
        
        let endpoint = YouTubeEndpoint.search(query: "\(title) trailer")
        let response: YouTubeSearchResponse = try await networkService.request(endpoint)
        
        guard let videoId = response.items.first?.id.videoId else {
            throw MediaRepositoryError.videoNotFound
        }
        
        await cacheService.set(key: cacheKey, value: videoId)
        
        return videoId
    }
}

/// YouTube API response models
struct YouTubeSearchResponse: Codable {
    let items: [YouTubeVideoItem]
}

struct YouTubeVideoItem: Codable {
    let id: YouTubeVideoId
}

struct YouTubeVideoId: Codable {
    let videoId: String
}

/// Media repository specific errors
enum MediaRepositoryError: LocalizedError {
    case videoNotFound
    case invalidConfiguration
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .videoNotFound:
            return "No video found for the requested title"
        case .invalidConfiguration:
            return "Invalid API configuration"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}
