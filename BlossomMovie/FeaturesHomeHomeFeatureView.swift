//
//  HomeFeatureView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

/// Main entry point for the Home feature
struct HomeFeatureView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var navigationPath = NavigationPath()
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            HomeView(
                navigationPath: $navigationPath,
                modelContext: modelContext
            )
            .navigationDestination(for: MediaItem.self) { item in
                MediaDetailFeatureView(mediaItem: item)
            }
        }
        .task {
            await dependencies.homeViewModel.loadContent()
        }
    }
}

#Preview {
    HomeFeatureView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}