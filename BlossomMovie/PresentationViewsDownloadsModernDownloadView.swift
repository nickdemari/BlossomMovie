//
//  ModernDownloadView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

struct ModernDownloadView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @State private var navigationPath = NavigationPath()
    @State private var downloadViewModel: DownloadViewModel?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Group {
                if let viewModel = downloadViewModel {
                    if viewModel.isLoading {
                        LoadingView()
                    } else if viewModel.hasDownloads {
                        DownloadContentView(
                            viewModel: viewModel,
                            onItemTapped: { item in
                                navigationPath.append(item)
                            },
                            onItemDeleted: { item in
                                viewModel.removeFromDownloads(item, context: modelContext)
                            }
                        )
                    } else {
                        EmptyDownloadsView()
                    }
                } else {
                    LoadingView()
                }
            }
            .navigationTitle(AppConstants.UI.downloadsTitle)
            .navigationBarTitleDisplayMode(.large)
            .navigationDestination(for: MediaItem.self) { item in
                MediaDetailView(mediaItem: item)
                    .environment(\.dependencies, dependencies)
            }
            .alert("Error", isPresented: .constant(downloadViewModel?.errorMessage != nil)) {
                Button("OK") {
                    downloadViewModel?.clearError()
                }
            } message: {
                if let errorMessage = downloadViewModel?.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .onAppear {
            if downloadViewModel == nil {
                downloadViewModel = dependencies.createDownloadViewModel()
                downloadViewModel?.loadDownloadedItems(from: modelContext)
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.downloadsList)
    }
}

// MARK: - Download Content View
private struct DownloadContentView: View {
    @Bindable var viewModel: DownloadViewModel
    let onItemTapped: (MediaItem) -> Void
    let onItemDeleted: (MediaItem) -> Void
    
    var body: some View {
        List {
            ForEach(viewModel.downloadedItems) { item in
                DownloadItemRow(
                    item: item,
                    onTap: { onItemTapped(item) },
                    onDelete: { onItemDeleted(item) }
                )
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding(.horizontal, AppConstants.Layout.standardPadding)
                .padding(.vertical, AppConstants.Layout.compactPadding)
            }
        }
        .listStyle(.plain)
    }
}

// MARK: - Download Item Row
private struct DownloadItemRow: View {
    let item: MediaItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.standardPadding) {
            // Poster
            AsyncImage(url: URL(string: item.fullPosterURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
            }
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            
            // Content
            VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                Text(item.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                
                if !item.displayDate.isEmpty {
                    Text(String(item.displayDate.prefix(4)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label {
                        Text(item.formattedRating)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Text(item.type?.displayName ?? "")
                        .font(.caption)
                        .padding(.horizontal, AppConstants.Layout.compactPadding)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                }
                
                if let overview = item.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: AppConstants.Layout.compactPadding) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .font(.title3)
                        .foregroundColor(.red)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.deleteButton)
                .accessibilityLabel("Delete downloaded item")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
        .confirmationDialog(
            "Remove Download",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove \"\(item.displayTitle)\" from your downloads?")
        }
    }
}

// MARK: - Empty Downloads View
private struct EmptyDownloadsView: View {
    var body: some View {
        EmptyStateView(
            title: "No Downloads",
            message: "Movies and TV shows you download will appear here",
            systemImage: "arrow.down.circle"
        )
        .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.emptyDownloads)
    }
}

#Preview {
    ModernDownloadView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}