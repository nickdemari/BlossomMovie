//
//  MediaDetailView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI
import SwiftData

struct MediaDetailView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?

    // MARK: - Computed State for Children
    private var isDownloaded: Bool {
        dependencies.downloadViewModel.isDownloaded(mediaItem)
    }

    private var releaseInfo: String {
        viewModel?.formattedReleaseInfo ?? ""
    }

    private var hasTrailer: Bool {
        viewModel?.hasTrailer ?? false
    }

    private var isLoadingTrailer: Bool {
        viewModel?.isLoadingTrailer ?? false
    }

    // MARK: - Action Handlers
    private func handlePlayTrailer() async {
        await viewModel?.loadTrailer()
    }

    private func handleDownloadToggle() {
        if isDownloaded {
            dependencies.downloadViewModel.removeFromDownloads(mediaItem, context: modelContext)
        } else {
            dependencies.downloadViewModel.addToDownloads(mediaItem, context: modelContext)
        }
    }

    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
                // Hero Image/Video Section
                MediaDetailHeroView(
                    mediaItem: mediaItem,
                    hasTrailer: hasTrailer,
                    isLoadingTrailer: isLoadingTrailer,
                    onPlayTapped: handlePlayTrailer
                )

                // Content Section
                VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
                    MediaDetailContentView(
                        mediaItem: mediaItem,
                        releaseInfo: releaseInfo,
                        hasTrailer: hasTrailer,
                        isDownloaded: isDownloaded,
                        youtubeEmbedURL: viewModel?.youtubeEmbedURL,
                        onPlayTrailerTapped: { Task { await handlePlayTrailer() } },
                        onDownloadTapped: handleDownloadToggle
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
    let previewContainer = try? ModelContainer(
        for: MediaItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return NavigationStack {
        MediaDetailView(
            mediaItem: MediaItem.previewItems[0],
            viewModel: nil
        )
    }
    .injectDependencies()
    .modelContainer(previewContainer ?? (try! ModelContainer(for: MediaItem.self)))
}
