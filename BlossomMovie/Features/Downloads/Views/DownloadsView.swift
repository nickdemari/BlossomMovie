//
//  DownloadsView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI
import SwiftData

struct DownloadsView: View {
    @Binding var navigationPath: NavigationPath
    @Binding var downloadViewModel: DownloadViewModel?
    let modelContext: ModelContext
    
    var body: some View {
        Group {
            if let viewModel = downloadViewModel {
                if viewModel.isLoading {
                    LoadingView()
                } else if viewModel.hasDownloads {
                    DownloadsContentView(
                        viewModel: viewModel,
                        onItemTapped: { item in
                            navigationPath.append(item)
                        },
                        onItemDeleted: { item in
                            viewModel.removeFromDownloads(item, context: modelContext)
                        }
                    )
                } else {
                    DownloadsEmptyStateView()
                }
            } else {
                LoadingView()
            }
        }
        .navigationTitle(AppConstants.UI.downloadsTitle)
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: .constant(downloadViewModel?.errorMessage != nil)) {
            Button("OK") {
                downloadViewModel?.clearError()
            }
        } message: {
            if let errorMessage = downloadViewModel?.errorMessage {
                Text(errorMessage)
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.downloadsList)
    }
}

#Preview {
    NavigationStack {
        DownloadsView(
            navigationPath: .constant(NavigationPath()),
            downloadViewModel: .constant(DependencyContainer.shared.createDownloadViewModel()),
            modelContext: ModelContext(
                try! ModelContainer(for: MediaItem.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
            )
        )
    }
    .injectDependencies()
}