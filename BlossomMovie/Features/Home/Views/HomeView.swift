//
//  HomeView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath

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
                            dependencies.downloadViewModel.addToDownloads(item, context: modelContext)
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
    let previewContainer = try? ModelContainer(
        for: MediaItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return NavigationStack {
        HomeView(navigationPath: .constant(NavigationPath()))
    }
    .injectDependencies()
    .modelContainer(previewContainer ?? (try! ModelContainer(for: MediaItem.self)))
}
