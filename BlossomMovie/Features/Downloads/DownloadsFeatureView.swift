//
//  DownloadsFeatureView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

/// Main entry point for the Downloads feature
struct DownloadsFeatureView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var downloadViewModel: DownloadViewModel?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            DownloadsView(
                navigationPath: $navigationPath,
                downloadViewModel: $downloadViewModel,
                modelContext: modelContext
            )
            .navigationDestination(for: MediaItem.self) { item in
                MediaDetailFeatureView(mediaItem: item)
            }
        }
        .onAppear {
            if downloadViewModel == nil {
                downloadViewModel = dependencies.createDownloadViewModel()
                downloadViewModel?.loadDownloadedItems(from: modelContext)
            }
        }
    }
}

#Preview {
    DownloadsFeatureView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}