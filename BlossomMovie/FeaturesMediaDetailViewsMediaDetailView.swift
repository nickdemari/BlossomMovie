//
//  MediaDetailView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

struct MediaDetailView: View {
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?
    let downloadViewModel: DownloadViewModel?
    let modelContext: ModelContext
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
                // Hero Image/Video Section
                MediaDetailHeroView(
                    mediaItem: mediaItem,
                    viewModel: viewModel
                )
                
                // Content Section
                VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
                    MediaDetailContentView(
                        mediaItem: mediaItem,
                        viewModel: viewModel,
                        downloadViewModel: downloadViewModel,
                        modelContext: modelContext
                    )
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
            }
        }
        .ignoresSafeArea(.container, edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(mediaItem.displayTitle)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MediaDetailView(
            mediaItem: MediaItem.previewItems[0],
            viewModel: nil,
            downloadViewModel: nil,
            modelContext: ModelContext(
                try! ModelContainer(for: MediaItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            )
        )
    }
    .injectDependencies()
}