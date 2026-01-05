//
//  DownloadsContentView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct DownloadsContentView: View {
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

#Preview {
    DownloadsContentView(
        viewModel: DependencyContainer.shared.createDownloadViewModel(),
        onItemTapped: { _ in },
        onItemDeleted: { _ in }
    )
    .injectDependencies()
}