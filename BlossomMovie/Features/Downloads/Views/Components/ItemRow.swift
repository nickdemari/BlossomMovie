//
//  DownloadItemRow.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct DownloadItemRow: View {
    let item: MediaItem
    let onTap: () -> Void
    let onDelete: () -> Void
    
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        HStack(spacing: AppConstants.Layout.standardPadding) {
            // Poster
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
            .frame(width: 80, height: 120)
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            
            // Content
            VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
                Text(item.displayTitle)
                    .font(.headline)
                    .lineLimit(2)
                
                if !item.displayDate.isEmpty {
                    Text(String(item.displayDate.prefix(4)))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label {
                        Text(item.formattedRating)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } icon: {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    
                    Spacer()
                    
                    Text(item.type?.displayName ?? "")
                        .font(.caption)
                        .padding(.horizontal, AppConstants.Layout.compactPadding)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.2))
                        )
                        .foregroundColor(.blue)
                }
                
                if let overview = item.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: AppConstants.Layout.compactPadding) {
                DownloadDeleteButton(
                    onDelete: { showDeleteConfirmation = true }
                )
            }
        }
        .padding(AppConstants.Layout.standardPadding)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
        .background(
            RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                .fill(Color(.secondarySystemBackground))
        )
        .confirmationDialog(
            "Remove Download",
            isPresented: $showDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                onDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to remove \"\(item.displayTitle)\" from your downloads?")
        }
    }
}

#Preview {
    List {
        ForEach(MediaItem.previewItems) { item in
            DownloadItemRow(
                item: item,
                onTap: {},
                onDelete: {}
            )
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
    }
    .listStyle(.plain)
}
