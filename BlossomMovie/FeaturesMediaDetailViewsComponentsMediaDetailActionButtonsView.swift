//
//  MediaDetailActionButtonsView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

struct MediaDetailActionButtonsView: View {
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?
    let downloadViewModel: DownloadViewModel?
    let modelContext: ModelContext
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.standardPadding) {
            if let viewModel = viewModel, viewModel.hasTrailer {
                Button {
                    Task {
                        await viewModel.loadTrailer()
                    }
                } label: {
                    Label("Play Trailer", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            
            Button {
                if let downloadViewModel = downloadViewModel {
                    if downloadViewModel.isDownloaded(mediaItem) {
                        downloadViewModel.removeFromDownloads(mediaItem, context: modelContext)
                    } else {
                        downloadViewModel.addToDownloads(mediaItem, context: modelContext)
                    }
                }
            } label: {
                let isDownloaded = downloadViewModel?.isDownloaded(mediaItem) ?? false
                Label(
                    isDownloaded ? "Remove" : "Download",
                    systemImage: isDownloaded ? "trash" : "arrow.down.circle"
                )
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }
}

#Preview {
    MediaDetailActionButtonsView(
        mediaItem: MediaItem.previewItems[0],
        viewModel: nil,
        downloadViewModel: nil,
        modelContext: ModelContext(
            try! ModelContainer(for: MediaItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        )
    )
    .padding()
    .injectDependencies()
}