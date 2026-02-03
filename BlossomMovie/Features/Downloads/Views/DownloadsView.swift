//
//  DownloadsView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI
import SwiftData

struct DownloadsView: View {
    @Environment(\.dependencies) private var dependencies
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath

    var body: some View {
        Group {
            if dependencies.downloadViewModel.isLoading {
                LoadingView()
            } else if dependencies.downloadViewModel.hasDownloads {
                DownloadsContentView(
                    viewModel: dependencies.downloadViewModel,
                    onItemTapped: { item in
                        navigationPath.append(item)
                    },
                    onItemDeleted: { item in
                        dependencies.downloadViewModel.removeFromDownloads(item, context: modelContext)
                    }
                )
            } else {
                DownloadsEmptyStateView()
            }
        }
        .navigationTitle(AppConstants.UI.downloadsTitle)
        .navigationBarTitleDisplayMode(.large)
        .alert("Error", isPresented: .constant(dependencies.downloadViewModel.errorMessage != nil)) {
            Button("OK") {
                dependencies.downloadViewModel.clearError()
            }
        } message: {
            if let errorMessage = dependencies.downloadViewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.downloadsList)
    }
}

#Preview {
    let previewContainer = try? ModelContainer(
        for: MediaItem.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )

    return NavigationStack {
        DownloadsView(navigationPath: .constant(NavigationPath()))
    }
    .injectDependencies()
    .modelContainer(previewContainer ?? (try! ModelContainer(for: MediaItem.self)))
}
