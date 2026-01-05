//
//  MediaDetailView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import WebKit

struct MediaDetailView: View {
    let mediaItem: MediaItem
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: MediaDetailViewModel?
    @State private var downloadViewModel: DownloadViewModel?
    
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

// MARK: - Hero View
private struct MediaDetailHeroView: View {
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background Image
                AsyncImage(url: URL(string: mediaItem.fullBackdropURL ?? mediaItem.fullPosterURL ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .overlay {
                            ProgressView()
                                .tint(.white)
                        }
                }
                
                // Gradient Overlay
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.5),
                        .init(color: .black.opacity(0.8), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Play Button (if video available)
                if let viewModel = viewModel, viewModel.hasTrailer {
                    Button {
                        // Handle play action
                        Task {
                            await viewModel.loadTrailer()
                        }
                    } label: {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 64))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 8)
                    }
                } else if let viewModel = viewModel, viewModel.isLoadingTrailer {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                } else {
                    Button {
                        Task {
                            await viewModel?.loadTrailer()
                        }
                    } label: {
                        Image(systemName: "play.circle")
                            .font(.system(size: 64))
                            .foregroundColor(.white.opacity(0.8))
                            .shadow(color: .black.opacity(0.3), radius: 8)
                    }
                }
            }
        }
        .frame(height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

// MARK: - Content View
private struct MediaDetailContentView: View {
    let mediaItem: MediaItem
    let viewModel: MediaDetailViewModel?
    let downloadViewModel: DownloadViewModel?
    let modelContext: ModelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.standardPadding) {
            // Title and Rating
            VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                Text(mediaItem.displayTitle)
                    .font(.title.bold())
                    .foregroundColor(.primary)
                
                Text(viewModel?.formattedReleaseInfo ?? "")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                // Rating
                HStack {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { index in
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(index < Int(mediaItem.voteAverage / 2) ? .yellow : .gray.opacity(0.3))
                        }
                    }
                    
                    Text("\(mediaItem.formattedRating)/10")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Media Type Badge
                    Text(mediaItem.type?.displayName ?? "")
                        .font(.caption.weight(.medium))
                        .padding(.horizontal, AppConstants.Layout.compactPadding)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                }
            }
            
            // Action Buttons
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
            
            // Overview
            if let overview = mediaItem.overview, !overview.isEmpty {
                VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                    Text("Overview")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(overview)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineLimit(nil)
                }
            }
            
            // Additional Info
            VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                Text("Details")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                VStack(alignment: .leading, spacing: 8) {
                    DetailRow(title: "Popularity", value: String(format: "%.1f", mediaItem.popularity))
                    DetailRow(title: "Vote Count", value: "\(mediaItem.voteCount)")
                    
                    if let language = mediaItem.originalLanguage {
                        DetailRow(title: "Original Language", value: language.uppercased())
                    }
                }
            }
            
            // YouTube Video (if available)
            if let viewModel = viewModel, let youtubeURL = viewModel.youtubeEmbedURL {
                VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                    Text("Trailer")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    WebView(url: youtubeURL)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
                }
            }
        }
    }
}

// MARK: - Detail Row
private struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - WebView
struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update if needed
    }
}

#Preview {
    NavigationStack {
        MediaDetailView(mediaItem: MediaItem.previewItems[0])
            .injectDependencies()
            .modelContainer(for: MediaItem.self, inMemory: true)
    }
}