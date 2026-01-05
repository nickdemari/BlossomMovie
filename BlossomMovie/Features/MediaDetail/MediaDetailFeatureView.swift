//
//  MediaDetailFeatureView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

/// Main entry point for the Media Detail feature
struct MediaDetailFeatureView: View {
    let mediaItem: MediaItem
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MediaDetailViewModel?
    @State private var downloadViewModel: DownloadViewModel?
    
    var body: some View {
        MediaDetailView(
            mediaItem: mediaItem,
            viewModel: viewModel,
            downloadViewModel: downloadViewModel,
            modelContext: modelContext
        )
        .onAppear {
            if viewModel == nil {
                viewModel = dependencies.createMediaDetailViewModel(for: mediaItem)
            }
            if downloadViewModel == nil {
                downloadViewModel = dependencies.createDownloadViewModel()
                downloadViewModel?.loadDownloadedItems(from: modelContext)
            }
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