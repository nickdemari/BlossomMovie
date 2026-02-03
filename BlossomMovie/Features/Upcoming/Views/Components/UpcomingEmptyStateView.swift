//
//  UpcomingEmptyStateView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct UpcomingEmptyStateView: View {
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Upcoming Movies")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text("Check back later for new upcoming releases")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    UpcomingEmptyStateView()
}
