//
//  SearchResultCard.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct SearchResultCard: View {
    let item: MediaItem
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            AsyncImage(url: URL(string: item.fullPosterURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                
                if !item.displayDate.isEmpty {
                    Text(String(item.displayDate.prefix(4))) // Show year only
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    
                    Text(item.formattedRating)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
        ForEach(MediaItem.previewItems) { item in
            SearchResultCard(item: item, onTap: {})
        }
    }
    .padding()
}