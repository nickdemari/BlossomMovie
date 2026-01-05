//
//  DownloadsEmptyStateView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct DownloadsEmptyStateView: View {
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            Image(systemName: "arrow.down.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Downloads")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Movies and TV shows you download will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.emptyDownloads)
    }
}

#Preview {
    DownloadsEmptyStateView()
}