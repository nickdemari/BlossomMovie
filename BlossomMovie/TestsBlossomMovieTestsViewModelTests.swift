//
//  ConfigurationManagerTests.swift
//  BlossomMovieTests
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Testing
import Foundation
@testable import BlossomMovie

@Suite("Configuration Manager Tests")
struct ConfigurationManagerTests {
    
    @Test("Configuration Manager loads successfully in development")
    func testConfigurationLoadsInDevelopment() async throws {
        // Given
        let manager = await ConfigurationManager.shared
        
        // When
        await manager.loadConfiguration()
        
        // Then
        await MainActor.run {
            #expect(manager.isLoaded == true)
            #expect(manager.configuration != nil)
            #expect(manager.error == nil)
        }
    }
    
    @Test("Configuration contains required properties")
    func testConfigurationProperties() async throws {
        // Given
        let manager = await ConfigurationManager.shared
        await manager.loadConfiguration()
        
        // When
        let config = await manager.configuration
        
        // Then
        let configuration = try #require(config)
        #expect(!configuration.tmdbBaseURL.isEmpty)
        #expect(!configuration.tmdbAPIKey.isEmpty)
        #expect(!configuration.youtubeBaseURL.isEmpty)
        #expect(!configuration.youtubeAPIKey.isEmpty)
        #expect(!configuration.youtubeSearchURL.isEmpty)
    }
}

@Suite("Media Item Tests")
struct MediaItemTests {
    
    @Test("Media Item initialization with valid data")
    func testMediaItemInitialization() {
        // Given & When
        let mediaItem = MediaItem(
            id: 123,
            title: "Test Movie",
            overview: "A test movie overview",
            posterPath: "/test-poster.jpg",
            voteAverage: 7.5,
            mediaType: "movie"
        )
        
        // Then
        #expect(mediaItem.id == 123)
        #expect(mediaItem.displayTitle == "Test Movie")
        #expect(mediaItem.overview == "A test movie overview")
        #expect(mediaItem.formattedRating == "7.5")
        #expect(mediaItem.type == .movie)
        #expect(mediaItem.fullPosterURL == "https://image.tmdb.org/t/p/w500/test-poster.jpg")
    }
    
    @Test("Media Item handles TV show data correctly")
    func testTVShowHandling() {
        // Given & When
        let tvShow = MediaItem(
            id: 456,
            name: "Test TV Show",
            firstAirDate: "2023-01-01",
            mediaType: "tv"
        )
        
        // Then
        #expect(tvShow.displayTitle == "Test TV Show")
        #expect(tvShow.displayDate == "2023-01-01")
        #expect(tvShow.type == .tv)
    }
    
    @Test("Media Item provides fallback for missing data")
    func testFallbackValues() {
        // Given & When
        let mediaItem = MediaItem(id: 789)
        
        // Then
        #expect(mediaItem.displayTitle == "Unknown Title")
        #expect(mediaItem.displayDate.isEmpty)
        #expect(mediaItem.fullPosterURL == nil)
        #expect(mediaItem.type == nil)
    }
}

@Suite("Home View Model Tests")
struct HomeViewModelTests {
    
    @MainActor
    @Test("Home ViewModel initializes correctly")
    func testViewModelInitialization() {
        // Given
        let mockRepo = MockMediaRepository()
        let mockLogger = MockLogger()
        
        // When
        let viewModel = HomeViewModel(mediaRepository: mockRepo, logger: mockLogger)
        
        // Then
        #expect(viewModel.loadingState == .idle)
        #expect(viewModel.trendingMovies.isEmpty)
        #expect(viewModel.heroItem == nil)
        #expect(!viewModel.isLoading)
        #expect(!viewModel.hasContent)
    }
    
    @MainActor
    @Test("Home ViewModel loads content successfully")
    func testSuccessfulContentLoad() async throws {
        // Given
        let mockRepo = MockMediaRepository()
        let mockLogger = MockLogger()
        mockRepo.shouldSucceed = true
        mockRepo.mockMovies = MediaItem.previewItems
        
        let viewModel = HomeViewModel(mediaRepository: mockRepo, logger: mockLogger)
        
        // When
        await viewModel.loadContent()
        
        // Then
        #expect(viewModel.loadingState == .loaded)
        #expect(!viewModel.trendingMovies.isEmpty)
        #expect(viewModel.heroItem != nil)
        #expect(!viewModel.isLoading)
        #expect(viewModel.hasContent)
        #expect(viewModel.errorMessage == nil)
    }
    
    @MainActor
    @Test("Home ViewModel handles loading errors")
    func testErrorHandling() async {
        // Given
        let mockRepo = MockMediaRepository()
        let mockLogger = MockLogger()
        mockRepo.shouldSucceed = false
        
        let viewModel = HomeViewModel(mediaRepository: mockRepo, logger: mockLogger)
        
        // When
        await viewModel.loadContent()
        
        // Then
        if case .error(let message) = viewModel.loadingState {
            #expect(message.contains("Mock error"))
        } else {
            Issue.record("Expected error state")
        }
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage != nil)
    }
}

@Suite("Search View Model Tests")
struct SearchViewModelTests {
    
    @MainActor
    @Test("Search ViewModel initializes correctly")
    func testSearchViewModelInitialization() {
        // Given
        let mockRepo = MockMediaRepository()
        let mockLogger = MockLogger()
        
        // When
        let viewModel = SearchViewModel(mediaRepository: mockRepo, logger: mockLogger)
        
        // Then
        #expect(viewModel.searchState == .idle)
        #expect(viewModel.searchQuery.isEmpty)
        #expect(viewModel.selectedMediaType == .movie)
        #expect(viewModel.searchResults.isEmpty)
        #expect(!viewModel.isSearching)
        #expect(!viewModel.hasResults)
    }
    
    @MainActor
    @Test("Search ViewModel toggles media type correctly")
    func testMediaTypeToggle() {
        // Given
        let mockRepo = MockMediaRepository()
        let mockLogger = MockLogger()
        let viewModel = SearchViewModel(mediaRepository: mockRepo, logger: mockLogger)
        
        // When
        viewModel.toggleMediaType()
        
        // Then
        #expect(viewModel.selectedMediaType == .tv)
        
        // When
        viewModel.toggleMediaType()
        
        // Then
        #expect(viewModel.selectedMediaType == .movie)
    }
    
    @MainActor
    @Test("Search ViewModel clears results correctly")
    func testClearResults() {
        // Given
        let mockRepo = MockMediaRepository()
        let mockLogger = MockLogger()
        let viewModel = SearchViewModel(mediaRepository: mockRepo, logger: mockLogger)
        viewModel.searchQuery = "test"
        
        // When
        viewModel.clearResults()
        
        // Then
        #expect(viewModel.searchState == .idle)
        #expect(viewModel.searchResults.isEmpty)
    }
}