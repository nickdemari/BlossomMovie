//
//  MediaDetailPlayButton.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct MediaDetailPlayButton: View {
    let hasTrailer: Bool
    let isLoadingTrailer: Bool
    let onPlayTapped: () async -> Void

    var body: some View {
        Group {
            if hasTrailer {
                Button {
                    Task {
                        await onPlayTapped()
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                }
            } else if isLoadingTrailer {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            } else {
                Button {
                    Task {
                        await onPlayTapped()
                    }
                } label: {
                    Image(systemName: "play.circle")
                        .font(.system(size: 64))
                        .foregroundColor(.white.opacity(0.8))
                        .shadow(color: .black.opacity(0.3), radius: 8)
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black
        MediaDetailPlayButton(
            hasTrailer: true,
            isLoadingTrailer: false,
            onPlayTapped: {}
        )
    }
    .frame(height: 300)
}
