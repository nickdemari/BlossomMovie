//
//  FeatureModules.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import Foundation

/// This file serves as an index for all feature modules in the application.
/// 
/// ## Feature-Based Architecture Overview
/// 
/// The app is organized into the following feature modules:
/// 
/// ### Core Features
/// - **Home**: Landing screen with trending and top-rated content
/// - **Search**: Movie and TV show search functionality
/// - **Upcoming**: List of upcoming movie releases
/// - **Downloads**: User's downloaded/saved content management
/// - **MediaDetail**: Detailed view for movies and TV shows
/// 
/// ### Feature Structure
/// Each feature follows this structure:
/// ```
/// Features/
/// ├── FeatureName/
/// │   ├── FeatureNameFeatureView.swift     // Entry point
/// │   ├── Views/
/// │   │   ├── FeatureNameView.swift        // Main view
/// │   │   ├── FeatureNameContentView.swift // Content view
/// │   │   └── Components/                  // Feature-specific components
/// │   ├── ViewModels/                      // Feature-specific view models (if any)
/// │   └── Models/                          // Feature-specific models (if any)
/// ```
/// 
/// ### Shared Components
/// Components used across multiple features are located in:
/// ```
/// Shared/
/// ├── UIComponents/                        // Reusable UI components
/// ├── ViewModels/                          // Shared view models
/// └── Models/                              // Shared models
/// ```
/// 
/// ### Benefits of Feature-Based Architecture
/// 
/// 1. **Modularity**: Each feature is self-contained
/// 2. **Scalability**: Easy to add new features without affecting existing ones
/// 3. **Team Collaboration**: Different teams can work on different features
/// 4. **Testing**: Features can be tested independently
/// 5. **Code Reusability**: Shared components prevent duplication
/// 6. **Maintainability**: Changes in one feature don't affect others
/// 
/// ### Navigation Flow
/// ```
/// AppTabView
/// ├── HomeFeatureView → MediaDetailFeatureView
/// ├── SearchFeatureView → MediaDetailFeatureView
/// ├── UpcomingFeatureView → MediaDetailFeatureView
/// └── DownloadsFeatureView → MediaDetailFeatureView
/// ```

// MARK: - Feature Registration
enum AppFeatures: String, CaseIterable {
    case home = "Home"
    case search = "Search"
    case upcoming = "Upcoming"
    case downloads = "Downloads"
    case mediaDetail = "MediaDetail"
    
    var displayName: String {
        return rawValue
    }
    
    var systemIcon: String {
        switch self {
        case .home: return AppConstants.UI.homeIcon
        case .search: return AppConstants.UI.searchIcon
        case .upcoming: return AppConstants.UI.upcomingIcon
        case .downloads: return AppConstants.UI.downloadsIcon
        case .mediaDetail: return "info.circle"
        }
    }
}

// MARK: - Feature Documentation
extension AppFeatures {
    var description: String {
        switch self {
        case .home:
            return "Main landing screen displaying trending movies, TV shows, and top-rated content with hero section"
        case .search:
            return "Search functionality for discovering movies and TV shows with real-time results and filtering"
        case .upcoming:
            return "Curated list of upcoming movie releases with release dates and details"
        case .downloads:
            return "User's personal collection of downloaded/saved content for offline viewing"
        case .mediaDetail:
            return "Detailed information view for movies and TV shows including trailers and additional metadata"
        }
    }
}