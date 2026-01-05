//
//  MediaDetailPlayButton.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

struct MediaDetailPlayButton: View {
    let viewModel: MediaDetailViewModel?
    
    var body: some View {
        Group {
            if let viewModel = viewModel, viewModel.hasTrailer {
                Button {
                    Task {
                        await viewModel.loadTrailer()
                    }
                } label: {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 8)
                }
            } else if let viewModel = viewModel, viewModel.isLoadingTrailer {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            } else {
                Button {
                    Task {
                        await viewModel?.loadTrailer()
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
        MediaDetailPlayButton(viewModel: nil)
    }
    .frame(height: 300)
}