//
//  DownloadsFeatureView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI
import SwiftData

/// Main entry point for the Downloads feature
struct DownloadsFeatureView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            DownloadsView(navigationPath: $navigationPath)
                .navigationDestination(for: MediaItem.self) { item in
                    MediaDetailFeatureView(mediaItem: item)
                }
        }
        .task {
            // Load downloaded items on appear
            dependencies.downloadViewModel.loadDownloadedItems(from: modelContext)
        }
    }
}

#Preview {
    DownloadsFeatureView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}
