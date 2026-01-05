//
//  UpcomingMovieRow.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct UpcomingMovieRow: View {
    let movie: MediaItem
    let onTap: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.standardPadding) {
            // Poster
            AsyncImage(url: URL(string: movie.fullPosterURL ?? "")) { image in
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
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            
            // Content
            VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                Text(movie.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                
                if !movie.displayDate.isEmpty {
                    Label {
                        Text(formatReleaseDate(movie.displayDate))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    Label {
                        Text(movie.formattedRating)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                }
                
                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.tertiary)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func formatReleaseDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = formatter.date(from: dateString) else {
            return dateString
        }
        
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: date)
    }
}

#Preview {
    List {
        ForEach(MediaItem.previewItems) { movie in
            UpcomingMovieRow(movie: movie, onTap: {})
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets())
                .padding()
        }
    }
    .listStyle(.plain)
}