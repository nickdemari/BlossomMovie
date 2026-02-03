//
//  BlossomMovieApp.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI
import SwiftData

@main
struct BlossomMovieApp: App {
    
    // MARK: - Dependencies
    let dependencyContainer = DependencyContainer.shared
    
    var body: some Scene {
        WindowGroup {
            AppTabView()
                .injectDependencies(dependencyContainer)
                .modelContainer(for: MediaItem.self)
                .task {
                    // Ensure configuration is loaded on app start
                    await dependencyContainer.configurationManager.loadConfiguration()
                }
        }
    }
}

#Preview {
    AppTabView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}
