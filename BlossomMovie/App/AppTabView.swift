//
//  AppTabView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            Tab(AppConstants.UI.homeTitle, systemImage: AppConstants.UI.homeIcon) {
                HomeFeatureView()
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Tabs.homeTab)
            
            Tab(AppConstants.UI.upcomingTitle, systemImage: AppConstants.UI.upcomingIcon) {
                UpcomingFeatureView()
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Tabs.upcomingTab)
            
            Tab(AppConstants.UI.searchTitle, systemImage: AppConstants.UI.searchIcon) {
                SearchFeatureView()
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Tabs.searchTab)
            
            Tab(AppConstants.UI.downloadsTitle, systemImage: AppConstants.UI.downloadsIcon) {
                DownloadsFeatureView()
            }
            .accessibilityIdentifier(AccessibilityIdentifiers.Tabs.downloadsTab)
        }
        .tint(.blue)
    }
}

#Preview {
    AppTabView()
        .injectDependencies()
        .modelContainer(for: MediaItem.self, inMemory: true)
}