//
//  UpcomingFeatureView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

/// Main entry point for the Upcoming feature
struct UpcomingFeatureView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            UpcomingView(navigationPath: $navigationPath)
                .navigationDestination(for: MediaItem.self) { item in
                    MediaDetailFeatureView(mediaItem: item)
                }
        }
        .task {
            await dependencies.upcomingViewModel.loadUpcomingMovies()
        }
    }
}

#Preview {
    UpcomingFeatureView()
        .injectDependencies()
}
