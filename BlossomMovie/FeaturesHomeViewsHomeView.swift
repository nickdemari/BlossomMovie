//
//  HomeView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.dependencies) private var dependencies
    @Binding var navigationPath: NavigationPath
    let modelContext: ModelContext
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: AppConstants.Layout.standardPadding) {
                switch dependencies.homeViewModel.loadingState {
                case .idle:
                    EmptyView()
                case .loading:
                    LoadingView()
                case .loaded:
                    HomeContentView(
                        viewModel: dependencies.homeViewModel,
                        onItemTapped: { item in
                            navigationPath.append(item)
                        },
                        onDownloadTapped: { item in
                            dependencies.createDownloadViewModel()
                                .addToDownloads(item, context: modelContext)
                        }
                    )
                case .error(let message):
                    ErrorView(
                        message: message,
                        retryAction: {
                            Task {
                                await dependencies.homeViewModel.refresh()
                            }
                        }
                    )
                }
            }
        }
        .refreshable {
            await dependencies.homeViewModel.refresh()
        }
        .navigationTitle(AppConstants.UI.homeTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        HomeView(
            navigationPath: .constant(NavigationPath()),
            modelContext: ModelContext(
                try! ModelContainer(for: MediaItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            )
        )
    }
    .injectDependencies()
}