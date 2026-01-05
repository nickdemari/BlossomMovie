//
//  ButtonStyles.swift
//  BlossomMovie
//
//  Created by Enterprise Refactoring on 1/4/26.
//

import SwiftUI

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

#Preview {
    VStack(spacing: 16) {
        Button("Primary Button") {}
            .buttonStyle(PrimaryButtonStyle())
        
        Button("Secondary Button") {}
            .buttonStyle(SecondaryButtonStyle())
    }
    .padding()
}