//
//  ModernSearchView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct ModernSearchView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Search results
                SearchResultsView(
                    viewModel: dependencies.searchViewModel,
                    onItemTapped: { item in
                        navigationPath.append(item)
                    }
                )
            }
            .navigationTitle(dependencies.searchViewModel.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: Binding(
                    get: { dependencies.searchViewModel.searchQuery },
                    set: { dependencies.searchViewModel.searchQuery = $0 }
                ),
                prompt: dependencies.searchViewModel.searchPrompt
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dependencies.searchViewModel.toggleMediaType()
                    } label: {
                        Image(systemName: dependencies.searchViewModel.toggleButtonIcon)
                            .font(.title3)
                    }
                    .accessibilityIdentifier(AccessibilityIdentifiers.Search.mediaTypeToggle)
                    .accessibilityLabel("Toggle between movies and TV shows")
                }
            }
            .navigationDestination(for: MediaItem.self) { item in
                MediaDetailView(mediaItem: item)
                    .environment(\.dependencies, dependencies)
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Search.searchBar)
    }
}

// MARK: - Search Results View
private struct SearchResultsView: View {
    @Bindable var viewModel: SearchViewModel
    let onItemTapped: (MediaItem) -> Void
    
    private let columns = Array(repeating: GridItem(.flexible(), spacing: AppConstants.Layout.gridSpacing), 
                               count: AppConstants.Layout.gridColumns)
    
    var body: some View {
        Group {
            switch viewModel.searchState {
            case .idle:
                EmptyStateView(
                    title: "Start Searching",
                    message: "Enter a title to search for \(viewModel.selectedMediaType.displayName.lowercased())s",
                    systemImage: "magnifyingglass"
                )
                
            case .searching:
                LoadingView()
                
            case .results:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: AppConstants.Layout.gridSpacing) {
                        ForEach(viewModel.searchResults) { item in
                            SearchResultCard(item: item) {
                                onItemTapped(item)
                            }
                        }
                    }
                    .padding(AppConstants.Layout.standardPadding)
                }
                .accessibilityIdentifier(AccessibilityIdentifiers.Search.resultsGrid)
                
            case .noResults:
                EmptyStateView(
                    title: AppConstants.UI.noResultsMessage,
                    message: "Try adjusting your search terms or switch between movies and TV shows",
                    systemImage: "magnifyingglass"
                )
                .accessibilityIdentifier(AccessibilityIdentifiers.Search.noResultsView)
                
            case .error(let message):
                ErrorView(
                    message: message,
                    retryAction: {
                        viewModel.retrySearch()
                    }
                )
            }
        }
        .animation(.easeInOut(duration: AppConstants.Animation.defaultDuration), value: viewModel.searchState)
    }
}

// MARK: - Search Result Card
private struct SearchResultCard: View {
    let item: MediaItem
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
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
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                
                if !item.displayDate.isEmpty {
                    Text(String(item.displayDate.prefix(4))) // Show year only
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    
                    Text(item.formattedRating)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    ModernSearchView()
        .injectDependencies()
}