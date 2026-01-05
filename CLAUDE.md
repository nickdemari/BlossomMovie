# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BlossomMovie is an iOS 18+ SwiftUI application for browsing movies and TV shows using The Movie Database (TMDB) API. The app follows Clean Architecture principles with clear separation between Domain, Data, Presentation, and Feature layers.

## Setup Requirements

**API Configuration:**
Before building, you must configure API keys:

1. Copy the template file:
   ```bash
   cp BlossomMovie/APIConfig.json.template BlossomMovie/APIConfig.json
   ```

2. Edit `BlossomMovie/APIConfig.json` and replace the placeholder values:
   - `YOUR_TMDB_API_KEY_HERE` - Get your TMDB API key from https://www.themoviedb.org
   - `YOUR_YOUTUBE_API_KEY_HERE` - Get your YouTube API key from https://console.cloud.google.com

3. The app supports both `development` and `production` environments with separate configurations.

**Note:** `APIConfig.json` is git-ignored to protect API keys. Never commit this file to version control.

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

The project uses a **feature-based folder structure** that mirrors the Clean Architecture layers:

```
BlossomMovie/
├── App/                     - Application entry points
├── Features/                - Feature modules (Home, Search, Upcoming, Downloads, MediaDetail)
│   └── {Feature}/
│       ├── FeatureView.swift
│       └── Views/
│           ├── Components/
│           └── ...
├── Presentation/ViewModels/ - Centralized ViewModels
├── Data/                    - Data layer (Network, Repository, Cache)
├── Domain/Models/           - Domain models
├── Infrastructure/          - Cross-cutting concerns (DI, Logging, Constants)
├── Configuration/           - API configuration
├── Shared/UIComponents/     - Reusable UI components
└── Tests/                   - Test files and mocks
```

### Layers

**1. Infrastructure Layer**
- `Infrastructure/DependencyInjection/DependencyContainer.swift` - Singleton DI container managing all services with lazy loading
- `Configuration/ConfigurationManager.swift` - Manages API configuration and environment switching
- `Infrastructure/Constants/AppConstants.swift` - Centralized constants (UI, Layout, Accessibility IDs)
- `Infrastructure/Logger/Logger.swift` - Logging system with os.log integration

**2. Domain Layer**
- `Domain/Models/MediaItem.swift` - Core domain model
  - SwiftData `@Model` for persistence
  - Codable for API serialization
  - Computed properties: `fullPosterURL`, `fullBackdropURL`, `displayTitle`, `formattedRating`
  - Generic `TMDBResponse<T>` wrapper for API responses

**3. Data Layer**
- `Data/Network/NetworkService.swift` - Generic network abstraction
  - Protocol-based design (`NetworkServiceProtocol`, `Endpoint`)
  - `TMDBEndpoint` enum: trending, topRated, upcoming, search
  - `YouTubeEndpoint` for video search
  - Comprehensive `NetworkError` handling
- `Data/Repositories/MediaRepository.swift` - Repository pattern implementation
  - `MediaRepositoryProtocol` defines business operations
  - Transparent cache integration (check cache → fetch network → cache result)
- `Data/Cache/CacheService.swift` - Two-tier caching
  - `CacheService` - In-memory with time-based expiration (actor-based thread safety)
  - `PersistentCacheService` - UserDefaults-based persistence

**4. Presentation Layer**
- ViewModels in `Presentation/ViewModels/`
  - All use `@MainActor` for thread safety
  - All use `@Observable` macro for reactive updates
  - State management through enums (LoadingState, SearchState)
  - Dependency injection via constructor

**5. Features Layer**

Each feature follows consistent structure:
```
Features/{Home,Search,Upcoming,Downloads,MediaDetail}/
  ├── FeatureView.swift - Entry point with NavigationStack, injects ViewModel
  ├── Views/
  │   ├── {Feature}View.swift - Main view composition, manages navigation state
  │   ├── ContentView.swift - Business logic and loading states
  │   └── Components/ - Reusable UI components
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
- Mock files in `Tests/Mocks/MockServices.swift`
  - `MockMediaRepository` implements `MediaRepositoryProtocol`
  - `MockNetworkService` for network testing
  - Control flags: `shouldSucceed`, `mockData`

**Running Tests:**
- Tests require `@MainActor` annotation when testing ViewModels
- Preview data available in domain models for SwiftUI previews

## Adding a New Feature

1. Create feature folder: `Features/{FeatureName}/`
2. Create `Features/{FeatureName}/FeatureView.swift` - Entry point with NavigationStack
3. Create `Features/{FeatureName}/Views/{FeatureName}View.swift` - Main view using DependencyContainer from environment
4. Create `Features/{FeatureName}/Views/ContentView.swift` - Business logic for loading states
5. Create components in `Features/{FeatureName}/Views/Components/` - Reusable UI elements
6. Create `Presentation/ViewModels/{FeatureName}ViewModel.swift` - ViewModel with `@Observable` and `@MainActor`
7. Register ViewModel in `Infrastructure/DependencyInjection/DependencyContainer.swift`
8. If new data operations needed:
   - Add method to `MediaRepositoryProtocol` in `Data/Repositories/MediaRepository.swift`
   - Implement in `MediaRepository`
   - Add endpoint to `TMDBEndpoint` enum in `Data/Network/NetworkService.swift`
9. Add tab to `App/AppTabView.swift` if it's a main feature

## Error Handling

- `ConfigurationError` - Configuration loading failures
- `NetworkError` - HTTP, decoding, request failures (in `Data/Network/NetworkService.swift`)
- State-based errors in ViewModels (e.g., `LoadingState.error(String)`)
- All network operations use async/await with proper error propagation

## Environment Configuration

Switch between `development` and `production` in `Configuration/ConfigurationManager.swift`:
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
