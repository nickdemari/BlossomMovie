//
//  DownloadViewModel.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation
import SwiftData

/// Download/Favorites view model
@MainActor
@Observable
final class DownloadViewModel {
    
    // MARK: - Properties
    private(set) var downloadedItems: [MediaItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let logger: LoggerProtocol
    
    // MARK: - Initialization
    init(logger: LoggerProtocol) {
        self.logger = logger
    }
    
    // MARK: - Public Methods
    func loadDownloadedItems(from context: ModelContext) {
        isLoading = true
        logger.info("Loading downloaded items")
        
        do {
            let descriptor = FetchDescriptor<MediaItem>(sortBy: [SortDescriptor(\.id)])
            downloadedItems = try context.fetch(descriptor)
            isLoading = false
            logger.info("Downloaded items loaded: \(downloadedItems.count) items")
        } catch {
            errorMessage = "Failed to load downloaded items: \(error.localizedDescription)"
            isLoading = false
            logger.error(errorMessage ?? "Unknown error")
        }
    }
    
    func addToDownloads(_ item: MediaItem, context: ModelContext) {
        do {
            context.insert(item)
            try context.save()
            
            if !downloadedItems.contains(where: { $0.id == item.id }) {
                downloadedItems.append(item)
            }
            
            logger.info("Added item to downloads: \(item.displayTitle)")
        } catch {
            errorMessage = "Failed to add item to downloads: \(error.localizedDescription)"
            logger.error(errorMessage ?? "Unknown error")
        }
    }
    
    func removeFromDownloads(_ item: MediaItem, context: ModelContext) {
        do {
            // Find and delete the item
            let descriptor = FetchDescriptor<MediaItem>(
                predicate: #Predicate { $0.id == item.id }
            )
            let items = try context.fetch(descriptor)
            
            for itemToDelete in items {
                context.delete(itemToDelete)
            }
            
            try context.save()
            
            downloadedItems.removeAll { $0.id == item.id }
            logger.info("Removed item from downloads: \(item.displayTitle)")
        } catch {
            errorMessage = "Failed to remove item from downloads: \(error.localizedDescription)"
            logger.error(errorMessage ?? "Unknown error")
        }
    }
    
    func isDownloaded(_ item: MediaItem) -> Bool {
        return downloadedItems.contains { $0.id == item.id }
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Computed Properties
    var hasDownloads: Bool {
        !downloadedItems.isEmpty
    }
}