//
//  SearchFeatureView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

/// Main entry point for the Search feature
struct SearchFeatureView: View {
    @Environment(\.dependencies) private var dependencies
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            SearchView(navigationPath: $navigationPath)
                .navigationDestination(for: MediaItem.self) { item in
                    MediaDetailFeatureView(mediaItem: item)
                }
        }
    }
}

#Preview {
    SearchFeatureView()
        .injectDependencies()
}
