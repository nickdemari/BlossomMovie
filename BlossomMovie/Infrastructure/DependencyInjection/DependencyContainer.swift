//
//  DependencyContainer.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import Foundation
import SwiftUI

/// Dependency injection container
@MainActor
final class DependencyContainer: ObservableObject {
    
    // MARK: - Singleton
    static let shared = DependencyContainer()
    
    // MARK: - Services
    lazy var configurationManager: ConfigurationManager = {
        ConfigurationManager.shared
    }()
    
    lazy var logger: LoggerProtocol = {
        #if DEBUG
        return Logger(category: "BlossomMovie", minimumLogLevel: .debug)
        #else
        return Logger(category: "BlossomMovie", minimumLogLevel: .warning)
        #endif
    }()
    
    lazy var cacheService: CacheServiceProtocol = {
        CacheService(defaultExpiration: configurationManager.configuration?.cacheTimeout ?? 300)
    }()
    
    lazy var persistentCacheService: CacheServiceProtocol = {
        PersistentCacheService()
    }()
    
    lazy var networkService: NetworkServiceProtocol = {
        NetworkService(
            configurationManager: configurationManager,
            logger: logger
        )
    }()
    
    lazy var mediaRepository: MediaRepositoryProtocol = {
        MediaRepository(
            networkService: networkService,
            configurationManager: configurationManager,
            cacheService: cacheService
        )
    }()
    
    // MARK: - ViewModels
    lazy var homeViewModel: HomeViewModel = {
        HomeViewModel(
            mediaRepository: mediaRepository,
            logger: logger
        )
    }()
    
    lazy var searchViewModel: SearchViewModel = {
        SearchViewModel(
            mediaRepository: mediaRepository,
            logger: logger
        )
    }()
    
    lazy var upcomingViewModel: UpcomingViewModel = {
        UpcomingViewModel(
            mediaRepository: mediaRepository,
            logger: logger
        )
    }()
    
    // MARK: - Initialization
    private init() {}
    
    // MARK: - Public Methods
    func createDownloadViewModel() -> DownloadViewModel {
        return DownloadViewModel(logger: logger)
    }
    
    func createMediaDetailViewModel(for mediaItem: MediaItem) -> MediaDetailViewModel {
        return MediaDetailViewModel(
            mediaItem: mediaItem,
            mediaRepository: mediaRepository,
            logger: logger
        )
    }
}

/// Environment key for dependency injection
struct DependencyContainerKey: EnvironmentKey {
    static let defaultValue: DependencyContainer = DependencyContainer.shared
}

extension EnvironmentValues {
    var dependencies: DependencyContainer {
        get { self[DependencyContainerKey.self] }
        set { self[DependencyContainerKey.self] = newValue }
    }
}

/// View modifier for dependency injection
struct DependencyInjectionModifier: ViewModifier {
    let container: DependencyContainer
    
    func body(content: Content) -> some View {
        content
            .environment(\.dependencies, container)
    }
}

extension View {
    func injectDependencies(_ container: DependencyContainer = .shared) -> some View {
        modifier(DependencyInjectionModifier(container: container))
    }
}