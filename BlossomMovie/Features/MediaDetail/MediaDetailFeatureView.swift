//
//  MediaDetailFeatureView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

/// Main entry point for the Media Detail feature
struct MediaDetailFeatureView: View {
    let mediaItem: MediaItem
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MediaDetailViewModel?

    var body: some View {
        MediaDetailView(
            mediaItem: mediaItem,
            viewModel: viewModel
        )
        .task(id: mediaItem.id) {
            // Initialize ViewModel once per unique media item
            if viewModel == nil {
                viewModel = dependencies.createMediaDetailViewModel(for: mediaItem)
            }
            // Load downloaded items to check if current item is downloaded
            dependencies.downloadViewModel.loadDownloadedItems(from: modelContext)
        }
    }
}

#Preview {
    NavigationStack {
        MediaDetailFeatureView(mediaItem: MediaItem.previewItems[0])
            .injectDependencies()
            .modelContainer(for: MediaItem.self, inMemory: true)
    }
}
