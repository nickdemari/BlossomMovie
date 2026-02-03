//
//  MockServices.swift
//  BlossomMovieTests
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation
@testable import BlossomMovie

// MARK: - Mock Media Repository
final class MockMediaRepository: MediaRepositoryProtocol {
    
    var shouldSucceed = true
    var mockMovies: [MediaItem] = []
    var mockTVShows: [MediaItem] = []
    var mockVideoId = "test_video_id"
    
    func fetchTrending(mediaType: MediaType) async throws -> [MediaItem] {
        if !shouldSucceed {
            throw MockError.testError
        }
        
        switch mediaType {
        case .movie:
            return mockMovies
        case .tv:
            return mockTVShows
        }
    }
    
    func fetchTopRated(mediaType: MediaType) async throws -> [MediaItem] {
        if !shouldSucceed {
            throw MockError.testError
        }
        
        switch mediaType {
        case .movie:
            return mockMovies
        case .tv:
            return mockTVShows
        }
    }
    
    func fetchUpcoming() async throws -> [MediaItem] {
        if !shouldSucceed {
            throw MockError.testError
        }
        
        return mockMovies
    }
    
    func search(query: String, mediaType: MediaType) async throws -> [MediaItem] {
        if !shouldSucceed {
            throw MockError.testError
        }
        
        if query.isEmpty {
            return []
        }
        
        switch mediaType {
        case .movie:
            return mockMovies.filter { $0.displayTitle.lowercased().contains(query.lowercased()) }
        case .tv:
            return mockTVShows.filter { $0.displayTitle.lowercased().contains(query.lowercased()) }
        }
    }
    
    func fetchVideoId(for title: String) async throws -> String {
        if !shouldSucceed {
            throw MockError.testError
        }
        
        return mockVideoId
    }
}

// MARK: - Mock Network Service
final class MockNetworkService: NetworkServiceProtocol {
    
    var shouldSucceed = true
    var mockResponse: Any?
    
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T {
        if !shouldSucceed {
            throw NetworkError.requestFailed(MockError.testError)
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.decodingError(MockError.invalidMockData)
        }
        
        return response
    }
}

// MARK: - Mock Cache Service
final actor MockCacheService: CacheServiceProtocol {
    
    private var storage: [String: Data] = [:]
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    func get<T: Codable>(key: String) async -> T? {
        guard let data = storage[key] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }
    
    func set<T: Codable>(key: String, value: T) async {
        guard let data = try? encoder.encode(value) else { return }
        storage[key] = data
    }
    
    func remove(key: String) async {
        storage.removeValue(forKey: key)
    }
    
    func clearAll() async {
        storage.removeAll()
    }
}

// MARK: - Mock Configuration Manager
@MainActor
final class MockConfigurationManager: ObservableObject {
    
    @Published var configuration: APIConfiguration? = APIConfiguration(
        tmdbBaseURL: "https://api.themoviedb.org",
        tmdbAPIKey: "test_tmdb_key",
        youtubeBaseURL: "https://youtube.com/embed",
        youtubeAPIKey: "test_youtube_key",
        youtubeSearchURL: "https://www.googleapis.com/youtube/v3/search",
        enableLogging: false,
        cacheTimeout: 300
    )
    
    @Published var isLoaded = true
    @Published var error: ConfigurationError?
    
    func loadConfiguration() async {
        // Mock implementation - already loaded
    }
    
    func reloadConfiguration() async {
        await loadConfiguration()
    }
}

// MARK: - Mock Errors
enum MockError: LocalizedError {
    case testError
    case invalidMockData
    
    var errorDescription: String? {
        switch self {
        case .testError:
            return "Mock error for testing"
        case .invalidMockData:
            return "Invalid mock data"
        }
    }
}

// MARK: - Test Extensions
extension MediaItem {
    static var testMovies: [MediaItem] {
        return [
            MediaItem(
                id: 1,
                title: "Test Movie 1",
                overview: "First test movie",
                posterPath: "/test1.jpg",
                voteAverage: 7.0,
                mediaType: "movie"
            ),
            MediaItem(
                id: 2,
                title: "Test Movie 2",
                overview: "Second test movie",
                posterPath: "/test2.jpg",
                voteAverage: 8.0,
                mediaType: "movie"
            )
        ]
    }
    
    static var testTVShows: [MediaItem] {
        return [
            MediaItem(
                id: 101,
                name: "Test TV Show 1",
                overview: "First test TV show",
                posterPath: "/tv1.jpg",
                firstAirDate: "2023-01-01",
                voteAverage: 7.5,
                mediaType: "tv"
            ),
            MediaItem(
                id: 102,
                name: "Test TV Show 2",
                overview: "Second test TV show",
                posterPath: "/tv2.jpg",
                firstAirDate: "2023-02-01",
                voteAverage: 8.5,
                mediaType: "tv"
            )
        ]
    }
}