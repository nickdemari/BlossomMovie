//
//  LoadingView.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(.primary)
            
            Text(AppConstants.UI.loadingMessage)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoadingView()
}