//
//  SearchResultsView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct SearchResultsView: View {
    @Bindable var viewModel: SearchViewModel
    let onItemTapped: (MediaItem) -> Void
    
    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: AppConstants.Layout.gridSpacing), 
        count: AppConstants.Layout.gridColumns
    )
    
    var body: some View {
        Group {
            switch viewModel.searchState {
            case .idle:
                SearchEmptyStateView(
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
                SearchEmptyStateView(
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

#Preview {
    SearchResultsView(
        viewModel: DependencyContainer.shared.searchViewModel,
        onItemTapped: { _ in }
    )
    .injectDependencies()
}