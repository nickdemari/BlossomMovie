//
//  HomeMediaSectionView.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct HomeMediaSectionView: View {
    let title: String
    let items: [MediaItem]
    let onItemTapped: (MediaItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            HStack {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                
                Spacer()
            }
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: AppConstants.Layout.standardPadding) {
                    ForEach(items) { item in
                        MediaPosterView(item: item)
                            .onTapGesture {
                                onItemTapped(item)
                            }
                    }
                }
                .padding(.horizontal, AppConstants.Layout.standardPadding)
            }
        }
    }
}

#Preview {
    HomeMediaSectionView(
        title: "Trending Movies",
        items: MediaItem.previewItems,
        onItemTapped: { _ in }
    )
}
