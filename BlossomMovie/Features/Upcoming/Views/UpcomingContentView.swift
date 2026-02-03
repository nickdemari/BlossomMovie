//
//  UpcomingContentView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct UpcomingContentView: View {
    let viewModel: UpcomingViewModel
    let onItemTapped: (MediaItem) -> Void
    
    var body: some View {
        if viewModel.hasMovies {
            List {
                ForEach(viewModel.upcomingMovies) { movie in
                    UpcomingMovieRow(movie: movie) {
                        onItemTapped(movie)
                    }
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets())
                    .padding(.horizontal, AppConstants.Layout.standardPadding)
                    .padding(.vertical, AppConstants.Layout.compactPadding)
                }
            }
            .listStyle(.plain)
        } else {
            UpcomingEmptyStateView()
        }
    }
}

#Preview {
    UpcomingContentView(
        viewModel: DependencyContainer.shared.upcomingViewModel,
        onItemTapped: { _ in }
    )
    .injectDependencies()
}
