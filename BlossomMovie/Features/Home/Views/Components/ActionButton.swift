//
//  HomeActionButton.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct HomeActionButton: View {
    let title: String
    let icon: String
    let style: ActionButtonStyle
    let action: () -> Void

    enum ActionButtonStyle {
        case primary, secondary
    }

    init(
        title: String,
        icon: String,
        style: ActionButtonStyle = .primary,
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

#Preview {
    VStack {
        HomeActionButton(
            title: "Play",
            icon: "play.circle",
            style: .primary,
            action: {}
        )

        HomeActionButton(
            title: "Download",
            icon: "arrow.down.circle",
            style: .secondary,
            action: {}
        )
    }
    .padding()
    .background(.black)
}
