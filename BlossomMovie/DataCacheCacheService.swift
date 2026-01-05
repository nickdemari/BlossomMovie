//
//  CacheService.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
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
        
        var isExpired: Bool {
            return Date() > expirationDate
        }
    }
    
    // MARK: - Properties
    private var cache: [String: CacheItem] = [:]
    private let defaultExpiration: TimeInterval
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    init(defaultExpiration: TimeInterval = 300) { // 5 minutes default
        self.defaultExpiration = defaultExpiration
    }
    
    // MARK: - CacheServiceProtocol Implementation
    func get<T: Codable>(key: String) async -> T? {
        // Clean up expired items first
        await cleanupExpiredItems()
        
        guard let item = cache[key], !item.isExpired else {
            cache.removeValue(forKey: key)
            return nil
        }
        
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
            let item = CacheItem(data: data, expirationDate: expirationDate)
            cache[key] = item
        } catch {
            // Handle encoding error - could log this
            print("Failed to encode cache item for key: \(key), error: \(error)")
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
}

/// Persistent cache service using UserDefaults
final class PersistentCacheService: CacheServiceProtocol {
    
    // MARK: - Properties
    private let userDefaults: UserDefaults
    private let keyPrefix: String
    private let defaultExpiration: TimeInterval
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // MARK: - Initialization
    init(
        userDefaults: UserDefaults = .standard,
        keyPrefix: String = "BlossomCache_",
        defaultExpiration: TimeInterval = 3600 // 1 hour default for persistent cache
    ) {
        self.userDefaults = userDefaults
        self.keyPrefix = keyPrefix
        self.defaultExpiration = defaultExpiration
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
            print("Failed to encode persistent cache item for key: \(key), error: \(error)")
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