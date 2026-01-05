//
//  ConfigurationManager.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation

/// Environment types for configuration
enum Environment: String, CaseIterable {
    case development = "development"
    case production = "production"
    
    static var current: Environment {
        #if DEBUG
        return .development
        #else
        return .production
        #endif
    }
}

/// Configuration model for API settings
struct APIConfiguration: Codable {
    let tmdbBaseURL: String
    let tmdbAPIKey: String
    let youtubeBaseURL: String
    let youtubeAPIKey: String
    let youtubeSearchURL: String
    let enableLogging: Bool
    let cacheTimeout: TimeInterval
}

/// Environment configurations container
struct EnvironmentConfiguration: Codable {
    let development: APIConfiguration
    let production: APIConfiguration
}

/// Centralized configuration manager
@MainActor
final class ConfigurationManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = ConfigurationManager()
    
    // MARK: - Properties
    @Published private(set) var configuration: APIConfiguration?
    @Published private(set) var isLoaded = false
    @Published private(set) var error: ConfigurationError?
    
    private let environment: Environment
    
    // MARK: - Initialization
    private init(environment: Environment = .current) {
        self.environment = environment
        Task {
            await loadConfiguration()
        }
    }
    
    // MARK: - Public Methods
    func loadConfiguration() async {
        do {
            let config = try await loadConfigurationFromBundle()
            await MainActor.run {
                self.configuration = config
                self.isLoaded = true
                self.error = nil
            }
        } catch let configError as ConfigurationError {
            await MainActor.run {
                self.error = configError
                self.isLoaded = false
            }
        } catch {
            await MainActor.run {
                self.error = .unknownError(error)
                self.isLoaded = false
            }
        }
    }
    
    func reloadConfiguration() async {
        await MainActor.run {
            self.isLoaded = false
            self.error = nil
        }
        await loadConfiguration()
    }
    
    // MARK: - Private Methods
    private func loadConfigurationFromBundle() async throws -> APIConfiguration {
        guard let url = Bundle.main.url(forResource: "APIConfig", withExtension: "json") else {
            throw ConfigurationError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: url)
            let environmentConfig = try JSONDecoder().decode(EnvironmentConfiguration.self, from: data)
            
            switch environment {
            case .development:
                return environmentConfig.development
            case .production:
                return environmentConfig.production
            }
        } catch let decodingError as DecodingError {
            throw ConfigurationError.decodingFailed(decodingError)
        } catch {
            throw ConfigurationError.dataLoadingFailed(error)
        }
    }
}

/// Configuration-specific errors
enum ConfigurationError: LocalizedError, Equatable {
    case fileNotFound
    case decodingFailed(DecodingError)
    case dataLoadingFailed(Error)
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Configuration file not found in app bundle"
        case .decodingFailed(let error):
            return "Failed to decode configuration: \(error.localizedDescription)"
        case .dataLoadingFailed(let error):
            return "Failed to load configuration data: \(error.localizedDescription)"
        case .unknownError(let error):
            return "Unknown configuration error: \(error.localizedDescription)"
        }
    }
    
    static func == (lhs: ConfigurationError, rhs: ConfigurationError) -> Bool {
        switch (lhs, rhs) {
        case (.fileNotFound, .fileNotFound):
            return true
        case (.decodingFailed(let lhsError), .decodingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.dataLoadingFailed(let lhsError), .dataLoadingFailed(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        case (.unknownError(let lhsError), .unknownError(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}