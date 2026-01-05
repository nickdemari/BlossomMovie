//
//  SearchMediaTypeButton.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct SearchMediaTypeButton: View {
    @Bindable var viewModel: SearchViewModel
    
    var body: some View {
        Button {
            viewModel.toggleMediaType()
        } label: {
            Image(systemName: viewModel.toggleButtonIcon)
                .font(.title3)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Search.mediaTypeToggle)
        .accessibilityLabel("Toggle between movies and TV shows")
    }
}

#Preview {
    SearchMediaTypeButton(viewModel: DependencyContainer.shared.searchViewModel)
        .injectDependencies()
}