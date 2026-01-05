//
//  MediaDetailContentView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

struct MediaDetailContentView: View {
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?
    let downloadViewModel: DownloadViewModel?
    let modelContext: ModelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
            // Title and Rating
            MediaDetailHeaderView(
                mediaItem: mediaItem,
                viewModel: viewModel
            )
            
            // Action Buttons
            MediaDetailActionButtonsView(
                mediaItem: mediaItem,
                viewModel: viewModel,
                downloadViewModel: downloadViewModel,
                modelContext: modelContext
            )
            
            // Overview
            if let overview = mediaItem.overview, !overview.isEmpty {
                MediaDetailOverviewView(overview: overview)
            }
            
            // Additional Info
            MediaDetailInfoView(mediaItem: mediaItem)
            
            // YouTube Video (if available)
            if let viewModel = viewModel, let youtubeURL = viewModel.youtubeEmbedURL {
                MediaDetailTrailerView(youtubeURL: youtubeURL)
            }
        }
    }
}

#Preview {
    ScrollView {
        MediaDetailContentView(
            mediaItem: MediaItem.previewItems[0],
            viewModel: nil,
            downloadViewModel: nil,
            modelContext: ModelContext(
                try! ModelContainer(for: MediaItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            )
        )
        .padding()
    }
    .injectDependencies()
}