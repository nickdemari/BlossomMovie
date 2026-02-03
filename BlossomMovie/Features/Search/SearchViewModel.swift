//
//  SearchViewModel.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation

/// Search view model with modern architecture
@MainActor
@Observable
final class SearchViewModel {
    
    // MARK: - State
    enum SearchState: Equatable {
        case idle
        case searching
        case results([MediaItem])
        case noResults
        case error(String)
    }
    
    // MARK: - Properties
    private(set) var searchState: SearchState = .idle
    private(set) var searchResults: [MediaItem] = []
    var searchQuery: String = "" {
        didSet {
            if searchQuery != oldValue {
                searchTask?.cancel()
                if searchQuery.isEmpty {
                    clearResults()
                } else {
                    scheduleSearch()
                }
            }
        }
    }
    var selectedMediaType: MediaType = .movie {
        didSet {
            if selectedMediaType != oldValue && !searchQuery.isEmpty {
                performSearch()
            }
        }
    }
    
    // MARK: - Private Properties
    private var searchTask: Task<Void, Never>?
    private let mediaRepository: MediaRepositoryProtocol
    private let logger: LoggerProtocol
    private let debounceDelay: UInt64 = 500_000_000 // 0.5 seconds in nanoseconds
    
    // MARK: - Initialization
    init(mediaRepository: MediaRepositoryProtocol, logger: LoggerProtocol) {
        self.mediaRepository = mediaRepository
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func toggleMediaType() {
        selectedMediaType = selectedMediaType == .movie ? .tv : .movie
    }
    
    func clearResults() {
        searchTask?.cancel()
        searchState = .idle
        searchResults = []
    }
    
    func retrySearch() {
        guard !searchQuery.isEmpty else { return }
        performSearch()
    }
    
    // MARK: - Private Methods
    private func scheduleSearch() {
        searchTask?.cancel()
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: debounceDelay)
            
            if !Task.isCancelled {
                await performSearch()
            }
        }
    }
    
    private func performSearch() {
        let query = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            clearResults()
            return
        }
        
        searchTask?.cancel()
        searchState = .searching
        logger.info("Searching for '\(query)' in \(selectedMediaType.displayName)")
        
        searchTask = Task {
            do {
                let results = try await mediaRepository.search(
                    query: query,
                    mediaType: selectedMediaType
                )
                
                if !Task.isCancelled {
                    if results.isEmpty {
                        searchState = .noResults
                        searchResults = []
                    } else {
                        searchState = .results(results)
                        searchResults = results
                    }
                    logger.info("Search completed: \(results.count) results found")
                }
            } catch {
                if !Task.isCancelled {
                    let errorMessage = "Search failed: \(error.localizedDescription)"
                    searchState = .error(errorMessage)
                    searchResults = []
                    logger.error(errorMessage)
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    var isSearching: Bool {
        searchState == .searching
    }
    
    var hasResults: Bool {
        !searchResults.isEmpty
    }
    
    var showsNoResults: Bool {
        searchState == .noResults
    }
    
    var errorMessage: String? {
        if case .error(let message) = searchState {
            return message
        }
        return nil
    }
    
    var searchPrompt: String {
        "Search \(selectedMediaType.displayName.lowercased())s..."
    }
    
    var navigationTitle: String {
        "\(selectedMediaType.displayName) Search"
    }
    
    var toggleButtonIcon: String {
        selectedMediaType == .movie ? "tv" : "film"
    }
}
