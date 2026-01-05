# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BlossomMovie is an iOS 18+ SwiftUI application for browsing movies and TV shows using The Movie Database (TMDB) API. The app follows Clean Architecture principles with clear separation between Domain, Data, Presentation, and Feature layers.

## Setup Requirements

**API Configuration:**
Before building, you must configure API keys in `APIConfig.json`:
- TMDB API key from https://www.themoviedb.org
- YouTube API key from https://console.cloud.google.com

The app supports both `development` and `production` environments with separate configurations.

## Build Commands

**Build the project:**
```bash
xcodebuild -project BlossomMovie.xcodeproj -scheme BlossomMovie -configuration Debug build
```

**Run tests:**
```bash
xcodebuild test -project BlossomMovie.xcodeproj -scheme BlossomMovie -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Run a single test:**
```bash
xcodebuild test -project BlossomMovie.xcodeproj -scheme BlossomMovie -destination 'platform=iOS Simulator,name=iPhone 15' -only-testing:BlossomMovieTests/<TestClassName>/<testMethodName>
```

**Clean build:**
```bash
xcodebuild clean -project BlossomMovie.xcodeproj -scheme BlossomMovie
```

## Architecture

### File Organization

The project uses **flat file structure with hierarchical naming conventions** instead of folder grouping. All files are in `BlossomMovie/` with prefixes indicating their layer:

- `App*` - Application entry points (AppBlossomMovieApp.swift, AppAppTabView.swift)
- `Configuration*` - Configuration management
- `Data*` - Data layer (Network, Repository, Cache)
- `Domain*` - Domain models
- `Features*` - Feature modules organized by feature name
- `Infrastructure*` - Cross-cutting concerns (DI, Logging, Constants)
- `Presentation*` - ViewModels and shared views
- `Tests*` - Test files and mocks

### Layers

**1. Infrastructure Layer**
- `InfrastructureDependencyInjectionDependencyContainer.swift` - Singleton DI container managing all services with lazy loading
- `ConfigurationConfigurationManager.swift` - Manages API configuration and environment switching
- `InfrastructureConstantsAppConstants.swift` - Centralized constants (UI, Layout, Accessibility IDs)
- `InfrastructureLoggerLogger.swift` - Logging system with os.log integration

**2. Domain Layer**
- `DomainModelsMediaItem.swift` - Core domain model
  - SwiftData `@Model` for persistence
  - Codable for API serialization
  - Computed properties: `fullPosterURL`, `fullBackdropURL`, `displayTitle`, `formattedRating`
  - Generic `TMDBResponse<T>` wrapper for API responses

**3. Data Layer**
- `DataNetworkNetworkService.swift` - Generic network abstraction
  - Protocol-based design (`NetworkServiceProtocol`, `Endpoint`)
  - `TMDBEndpoint` enum: trending, topRated, upcoming, search
  - `YouTubeEndpoint` for video search
  - Comprehensive `NetworkError` handling
- `DataRepositoriesMediaRepository.swift` - Repository pattern implementation
  - `MediaRepositoryProtocol` defines business operations
  - Transparent cache integration (check cache → fetch network → cache result)
- `DataCacheCacheService.swift` - Two-tier caching
  - `CacheService` - In-memory with time-based expiration (actor-based thread safety)
  - `PersistentCacheService` - UserDefaults-based persistence

**4. Presentation Layer**
- ViewModels in `PresentationViewModels*.swift`
  - All use `@MainActor` for thread safety
  - All use `@Observable` macro for reactive updates
  - State management through enums (LoadingState, SearchState)
  - Dependency injection via constructor

**5. Features Layer**

Each feature follows consistent structure:
```
FeaturesHome/Search/Upcoming/Downloads/MediaDetail*
  ├── *FeatureView - Entry point with NavigationStack, injects ViewModel
  ├── *View - Main view composition, manages navigation state
  ├── *ContentView - Business logic and loading states
  └── ViewsComponents* - Reusable UI components
```

Features are tab-based: Home, Upcoming, Search, Downloads

## Key Design Patterns

**Dependency Injection:**
- Singleton `DependencyContainer` with lazy-loaded services
- Environment-based injection via ViewModifier
- Protocol-oriented design for testability

**Repository Pattern:**
- Network abstraction through protocols
- Cache integration transparent to ViewModels
- Single source of truth for data operations

**MVVM with Clean Architecture:**
- ViewModels use `@Observable` for state management
- Clear separation: View → ViewModel → Repository → Network
- Feature-based organization with self-contained modules

## Data Persistence

**SwiftData:**
- `MediaItem` model marked with `@Model` decorator
- Unique constraint on `id` field
- ModelContainer initialized in `AppBlossomMovieApp.swift`
- Supports saving, sorting, and deletion

## Testing

**Test Infrastructure:**
- Swift Testing framework (using `@Test` macro)
- Protocol-based mocking (no third-party frameworks)
- Mock files in `TestsBlossomMovieTestsMocksMockServices.swift`
  - `MockMediaRepository` implements `MediaRepositoryProtocol`
  - `MockNetworkService` for network testing
  - Control flags: `shouldSucceed`, `mockData`

**Running Tests:**
- Tests require `@MainActor` annotation when testing ViewModels
- Preview data available in domain models for SwiftUI previews

## Adding a New Feature

1. Create `Features<Name><Name>FeatureView.swift` - Entry point with NavigationStack
2. Create `Features<Name>Views<Name>View.swift` - Main view using DependencyContainer from environment
3. Create `Features<Name>Views<Name>ContentView.swift` - Business logic for loading states
4. Create components in `Features<Name>ViewsComponents*.swift` - Reusable UI elements
5. Create `PresentationViewModels<Name>ViewModel.swift` - ViewModel with `@Observable` and `@MainActor`
6. Register ViewModel in `InfrastructureDependencyInjectionDependencyContainer.swift`
7. If new data operations needed:
   - Add method to `MediaRepositoryProtocol` in `DataRepositoriesMediaRepository.swift`
   - Implement in `MediaRepository`
   - Add endpoint to `TMDBEndpoint` enum in `DataNetworkNetworkService.swift`
8. Add tab to `AppAppTabView.swift` if it's a main feature

## Error Handling

- `ConfigurationError` - Configuration loading failures
- `NetworkError` - HTTP, decoding, request failures (in `DataNetworkNetworkService.swift`)
- State-based errors in ViewModels (e.g., `LoadingState.error(String)`)
- All network operations use async/await with proper error propagation

## Environment Configuration

Switch between `development` and `production` in `ConfigurationConfigurationManager.swift`:
```swift
@Published var currentEnvironment: Environment = .development // or .production
```

Configuration includes:
- API base URLs (TMDB, YouTube)
- API keys
- Logging enabled/disabled
- Cache timeout duration

## SwiftUI Preview Support

All domain models include static preview data for SwiftUI previews. Access via:
```swift
MediaItem.preview
MediaItem.previewList
```
