//
//  SharedComponents.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

// MARK: - Loading View
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

// MARK: - Error View
struct ErrorView: View {
    let message: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("Error")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(AppConstants.UI.retryButtonText, action: retryAction)
                .buttonStyle(PrimaryButtonStyle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    let buttonTitle: String?
    let buttonAction: (() -> Void)?
    
    init(
        title: String,
        message: String,
        systemImage: String,
        buttonTitle: String? = nil,
        buttonAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.buttonTitle = buttonTitle
        self.buttonAction = buttonAction
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Layout.standardPadding) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let buttonTitle = buttonTitle, let buttonAction = buttonAction {
                Button(buttonTitle, action: buttonAction)
                    .buttonStyle(PrimaryButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Media Poster View
struct MediaPosterView: View {
    let item: MediaItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Layout.compactPadding) {
            AsyncImage(url: URL(string: item.fullPosterURL ?? "")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: AppConstants.Layout.compactPosterWidth,
                        height: AppConstants.Layout.compactPosterHeight
                    )
                    .clipped()
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(
                        width: AppConstants.Layout.compactPosterWidth,
                        height: AppConstants.Layout.compactPosterHeight
                    )
                    .overlay {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius))
            .shadow(color: .black.opacity(0.2), radius: AppConstants.Layout.shadowRadius)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.displayTitle)
                    .font(.caption.weight(.semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                    
                    Text(item.formattedRating)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: AppConstants.Layout.compactPosterWidth, alignment: .leading)
        }
    }
}

// MARK: - Action Button
struct ActionButton: View {
    let title: String
    let icon: String
    let style: ButtonStyle
    let action: () -> Void
    
    enum ButtonStyle {
        case primary, secondary
    }
    
    init(
        title: String,
        icon: String,
        style: ButtonStyle = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: AppConstants.Layout.compactPadding) {
                Image(systemName: icon)
                    .font(.body.weight(.medium))
                
                Text(title)
                    .font(.body.weight(.medium))
            }
            .foregroundColor(style == .primary ? .black : .white)
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.vertical, AppConstants.Layout.compactPadding)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                    .fill(style == .primary ? .white : .white.opacity(0.2))
            )
        }
        .accessibilityIdentifier(style == .primary ? 
                                 AccessibilityIdentifiers.Home.playButton :
                                 AccessibilityIdentifiers.Home.downloadButton)
    }
}

// MARK: - Button Styles
struct PrimaryButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.vertical, AppConstants.Layout.compactPadding)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                    .fill(.blue)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: SwiftUI.ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.primary)
            .padding(.horizontal, AppConstants.Layout.standardPadding)
            .padding(.vertical, AppConstants.Layout.compactPadding)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.Layout.cornerRadius)
                    .stroke(.primary, lineWidth: 1)
                    .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            )
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}