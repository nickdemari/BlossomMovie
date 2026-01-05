//
//  UpcomingView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct UpcomingView: View {
    @Environment(\.dependencies) private var dependencies
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        Group {
            switch dependencies.upcomingViewModel.loadingState {
            case .idle:
                EmptyView()
            case .loading:
                LoadingView()
            case .loaded:
                UpcomingContentView(
                    viewModel: dependencies.upcomingViewModel,
                    onItemTapped: { item in
                        navigationPath.append(item)
                    }
                )
            case .error(let message):
                ErrorView(
                    message: message,
                    retryAction: {
                        Task {
                            await dependencies.upcomingViewModel.refresh()
                        }
                    }
                )
            }
        }
        .refreshable {
            await dependencies.upcomingViewModel.refresh()
        }
        .navigationTitle(AppConstants.UI.upcomingTitle)
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        UpcomingView(navigationPath: .constant(NavigationPath()))
    }
    .injectDependencies()
}