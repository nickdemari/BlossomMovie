//
//  CacheService.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation

/// Cache service protocol
protocol CacheServiceProtocol {
    func get<T: Codable>(key: String) async -> T?
    func set<T: Codable>(key: String, value: T) async
    func remove(key: String) async
    func clearAll() async
}

/// In-memory cache implementation with expiration
final actor CacheService: CacheServiceProtocol {
    
    // MARK: - Cache Item
    private struct CacheItem {
        let data: Data
        let expirationDate: Date
        var lastAccessedDate: Date

        var isExpired: Bool {
            return Date() > expirationDate
        }
    }
    
    // MARK: - Properties
    private var cache: [String: CacheItem] = [:]
    private let defaultExpiration: TimeInterval
    private let maxCacheSize: Int
    private let logger: LoggerProtocol?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization
    init(defaultExpiration: TimeInterval = 300, maxCacheSize: Int = 100, logger: LoggerProtocol? = nil) { // 5 minutes default, 100 items max
        self.defaultExpiration = defaultExpiration
        self.maxCacheSize = maxCacheSize
        self.logger = logger
    }
    
    // MARK: - CacheServiceProtocol Implementation
    func get<T: Codable>(key: String) async -> T? {
        // Clean up expired items first
        await cleanupExpiredItems()

        guard var item = cache[key], !item.isExpired else {
            cache.removeValue(forKey: key)
            return nil
        }

        // Update last accessed date for LRU tracking
        item.lastAccessedDate = Date()
        cache[key] = item

        do {
            return try decoder.decode(T.self, from: item.data)
        } catch {
            // Remove corrupted data
            cache.removeValue(forKey: key)
            return nil
        }
    }
    
    func set<T: Codable>(key: String, value: T) async {
        do {
            let data = try encoder.encode(value)
            let expirationDate = Date().addingTimeInterval(defaultExpiration)
            let item = CacheItem(
                data: data,
                expirationDate: expirationDate,
                lastAccessedDate: Date()
            )
            cache[key] = item

            // Evict least recently used items if needed
            await evictLRUIfNeeded()
        } catch {
            logger?.error("Failed to encode cache item for key: \(key), error: \(error)")
        }
    }
    
    func remove(key: String) async {
        cache.removeValue(forKey: key)
    }
    
    func clearAll() async {
        cache.removeAll()
    }
    
    // MARK: - Private Methods
    private func cleanupExpiredItems() async {
        let expiredKeys = cache.compactMap { key, item in
            item.isExpired ? key : nil
        }

        for key in expiredKeys {
            cache.removeValue(forKey: key)
        }
    }

    /// Evict least recently used items when cache exceeds max size
    private func evictLRUIfNeeded() async {
        guard cache.count > maxCacheSize else { return }

        // Sort by lastAccessedDate, oldest first
        let sortedKeys = cache.sorted {
            $0.value.lastAccessedDate < $1.value.lastAccessedDate
        }.map { $0.key }

        // Remove oldest 20% when limit exceeded
        let itemsToRemove = max(1, maxCacheSize / 5)
        for key in sortedKeys.prefix(itemsToRemove) {
            cache.removeValue(forKey: key)
        }
    }
}

/// Persistent cache service using UserDefaults
final class PersistentCacheService: CacheServiceProtocol {

    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let keyPrefix: String
    private let defaultExpiration: TimeInterval
    private let logger: LoggerProtocol?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    // MARK: - Initialization
    init(
        userDefaults: UserDefaults = .standard,
        keyPrefix: String = "BlossomCache_",
        defaultExpiration: TimeInterval = 3600, // 1 hour default for persistent cache
        logger: LoggerProtocol? = nil
    ) {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
        self.defaultExpiration = defaultExpiration
        self.logger = logger
    }
    
    // MARK: - CacheServiceProtocol Implementation
    func get<T: Codable>(key: String) async -> T? {
        let prefixedKey = keyPrefix + key
        let expirationKey = prefixedKey + "_expiration"
        
        // Check expiration
        let expirationTimestamp = userDefaults.double(forKey: expirationKey)
        if expirationTimestamp != 0 && Date().timeIntervalSince1970 > expirationTimestamp {
            await remove(key: key)
            return nil
        }
        
        // Get data
        guard let data = userDefaults.data(forKey: prefixedKey) else {
            return nil
        }
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            await remove(key: key)
            return nil
        }
    }
    
    func set<T: Codable>(key: String, value: T) async {
        do {
            let data = try encoder.encode(value)
            let prefixedKey = keyPrefix + key
            let expirationKey = prefixedKey + "_expiration"
            let expirationTimestamp = Date().addingTimeInterval(defaultExpiration).timeIntervalSince1970

            userDefaults.set(data, forKey: prefixedKey)
            userDefaults.set(expirationTimestamp, forKey: expirationKey)
        } catch {
            logger?.error("Failed to encode persistent cache item for key: \(key), error: \(error)")
        }
    }
    
    func remove(key: String) async {
        let prefixedKey = keyPrefix + key
        let expirationKey = prefixedKey + "_expiration"
        
        userDefaults.removeObject(forKey: prefixedKey)
        userDefaults.removeObject(forKey: expirationKey)
    }
    
    func clearAll() async {
        let keys = userDefaults.dictionaryRepresentation().keys
        let prefixedKeys = keys.filter { $0.hasPrefix(keyPrefix) }
        
        for key in prefixedKeys {
            userDefaults.removeObject(forKey: key)
        }
    }
}
