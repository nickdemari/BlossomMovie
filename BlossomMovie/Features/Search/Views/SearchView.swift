//
//  SearchView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dependencies) private var dependencies
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(spacing: 0) {
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
                SearchMediaTypeButton(viewModel: dependencies.searchViewModel)
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Search.searchBar)
    }
}

#Preview {
    NavigationStack {
        SearchView(navigationPath: .constant(NavigationPath()))
    }
    .injectDependencies()
}