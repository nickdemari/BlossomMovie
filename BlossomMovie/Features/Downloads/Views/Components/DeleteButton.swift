//
//  DownloadDeleteButton.swift
//  BlossomMovie
//
//  Created by Nick Demari on 1/4/26.
//

import SwiftUI

struct DownloadDeleteButton: View {
    let onDelete: () -> Void
    
    var body: some View {
        Button {
            onDelete()
        } label: {
            Image(systemName: "trash")
                .font(.title3)
                .foregroundColor(.red)
        }
        .accessibilityIdentifier(AccessibilityIdentifiers.Downloads.deleteButton)
        .accessibilityLabel("Delete downloaded item")
    }
}

#Preview {
    DownloadDeleteButton(onDelete: {})
        .padding()
}
