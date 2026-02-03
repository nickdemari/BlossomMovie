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

### Using xcodebuild (Traditional)

**Build the project:**
```bash
xcodebuild -project BlossomMovie.xcodeproj -scheme BlossomMovie -configuration Debug build
```

**Run tests:**
```bash
xcodebuild test -project BlossomMovie.xcodeproj -scheme BlossomMovie -destination 'platform=iOS Simulator,name=iPhone 15'
```

**Note:** There is currently no separate test target. Tests are located in `Tests_Temp/` but may need to be integrated into the main project structure.

**Clean build:**
```bash
xcodebuild clean -project BlossomMovie.xcodeproj -scheme BlossomMovie
```

### Using MCP Tools (Recommended)

The XcodeBuildMCP server provides convenient commands for building and running:

**Build for simulator:**
```bash
mcp-cli call XcodeBuildMCP/build_sim '{"scheme": "BlossomMovie"}'
```

**Build and run on simulator:**
```bash
mcp-cli call XcodeBuildMCP/build_run_sim '{"scheme": "BlossomMovie"}'
```

**List available simulators:**
```bash
mcp-cli call XcodeBuildMCP/list_sims '{}'
```

**Take screenshot:**
```bash
mcp-cli call XcodeBuildMCP/screenshot '{"outputPath": "/path/to/screenshot.png"}'
```

Always run `mcp-cli info XcodeBuildMCP/<tool>` first to check parameter requirements.

## Architecture

### File Organization

The project uses a **feature-based folder structure** that mirrors the Clean Architecture layers:

```
BlossomMovie/
├── App/                     - Application entry points
├── Features/                - Feature modules (Home, Search, Upcoming, Downloads, MediaDetail)
│   └── {Feature}/
│       ├── FeatureView.swift
│       ├── ViewModel.swift
│       └── Views/
│           ├── Components/
│           └── ...
├── Data/                    - Data layer (Network, Repository, Cache)
├── Domain/Models/           - Domain models
├── Infrastructure/          - Cross-cutting concerns (DI, Logging, Constants)
├── Configuration/           - API configuration
├── Shared/UIComponents/     - Reusable UI components (CachedAsyncImage, MediaPosterView, etc.)
└── Tests_Temp/              - Test files and mocks
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
- ViewModels are located within their respective feature folders
  - All use `@MainActor` for thread safety
  - All use `@Observable` macro for reactive updates
  - State management through enums (LoadingState, SearchState)
  - Dependency injection via constructor

**5. Features Layer**

Each feature follows a consistent structure with self-contained ViewModels:
```
Features/{Feature}/
  ├── {Feature}FeatureView.swift - Entry point with NavigationStack, injects ViewModel
  ├── {Feature}ViewModel.swift - Feature-specific ViewModel with business logic
  ├── Views/
  │   ├── {Feature}View.swift - Main view composition, manages navigation state
  │   ├── {Feature}ContentView.swift - Business logic and loading states
  │   └── Components/ - Feature-specific UI components
```

**Naming variations:**
- Search: Uses `ResultsView.swift` instead of ContentView
- MediaDetail: Uses `DetailView.swift` as the main view

Tab-based features: Home, Upcoming, Search, Downloads

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
- ViewModels use `@Observable` macro for state management (iOS 17+)
  - Replaces `@Published` and `ObservableObject` pattern
  - Automatic property observation without explicit publishers
  - All ViewModels also use `@MainActor` for thread-safe UI updates
- Clear separation: View → ViewModel → Repository → Network
- Feature-based organization with self-contained modules

## Data Persistence

**SwiftData:**
- `MediaItem` model marked with `@Model` decorator for SwiftData persistence
- Unique constraint on `id` field via `@Attribute(.unique)` to prevent duplicates
- ModelContainer initialized in `BlossomMovieApp.swift` at app startup
- Used by Downloads feature to save movies/shows for offline viewing
- `DownloadViewModel` handles all SwiftData operations:
  - Uses `FetchDescriptor` for querying with sorting
  - Uses `#Predicate` macro for type-safe filtering (iOS 17+)
  - All operations require `ModelContext` passed from views
  - CRUD: `context.insert()`, `context.fetch()`, `context.delete()`, `context.save()`
- In-memory container available for SwiftUI previews

## Testing

**Test Infrastructure:**
- Swift Testing framework (using `@Test` macro)
- Protocol-based mocking (no third-party frameworks)
- Test files located in `Tests_Temp/` directory
- Mock services in `Tests_Temp/Mocks/MockServices.swift`:
  - `MockMediaRepository` - implements `MediaRepositoryProtocol` with control flags (`shouldSucceed`, `mockMovies`, `mockTVShows`)
  - `MockNetworkService` - implements `NetworkServiceProtocol` for network testing
  - `MockCacheService` - actor-based cache mock for testing
  - `MockConfigurationManager` - configuration mock for testing
  - `MockLogger` - available in production code at `Infrastructure/Logger/Logger.swift` for testing

**Running Tests:**
- Tests require `@MainActor` annotation when testing ViewModels
- Use Swift Testing's `@Test` and `@Suite` macros for test organization
- Preview data available in domain models: `MediaItem.previewItems`

## Adding a New Feature

1. Create feature folder: `Features/{FeatureName}/`
2. Create `Features/{FeatureName}/{FeatureName}FeatureView.swift` - Entry point with NavigationStack
3. Create `Features/{FeatureName}/{FeatureName}ViewModel.swift` - ViewModel with `@Observable` and `@MainActor`
4. Create `Features/{FeatureName}/Views/{FeatureName}View.swift` - Main view using DependencyContainer from environment
5. Create `Features/{FeatureName}/Views/{FeatureName}ContentView.swift` - Business logic for loading states
6. Create components in `Features/{FeatureName}/Views/Components/` - Reusable UI elements
7. Register ViewModel in `Infrastructure/DependencyInjection/DependencyContainer.swift`
8. If new data operations needed:
   - Add method to `MediaRepositoryProtocol` in `Data/Repositories/MediaRepository.swift`
   - Implement in `MediaRepository`
   - Add endpoint to `TMDBEndpoint` enum in `Data/Network/NetworkService.swift`
9. Add tab to `App/AppTabView.swift` if it's a main feature

## Shared UI Components

**Location:** `Shared/UIComponents/`

- `CachedAsyncImage.swift` - Reusable async image component with placeholder, error handling, and convenience initializers for poster/backdrop images
- `MediaPosterView.swift` - Movie/TV show poster display component
- `ButtonStyles.swift` - Custom button styling
- `ErrorView.swift` - Error state UI component
- `LoadingView.swift` - Loading indicator component
- `WebView.swift` - Web content embedding (UIViewRepresentable)

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
MediaItem.previewItems  // Array of 3 sample items (movies and TV shows)
```

## Related Documentation

- `docs/viewmodel-reorganization.md` - Details on the feature-based architecture migration
- `AGENTS.md` - Available skills for AI assistants (iphone-apps, swift-concurrency)
