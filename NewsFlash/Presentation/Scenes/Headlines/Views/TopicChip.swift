//
//  TopicChip.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 06/09/2025.
//

import SwiftUI

// MARK: - TopicChip Component

struct TopicChip: View {
    let topic: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(topic)
                .font(.semibold(size: 13))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}
