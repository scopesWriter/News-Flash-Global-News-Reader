//
//  ArticleRow.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import SwiftUI

struct ArticleRow: View {
    // MARK: - Properties
    let item: HeadlineItemViewData

    // MARK: - Body
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            AsyncImage(url: item.imageURL) { phase in
                switch phase {
                case .empty, .failure:
                    placeholderImage
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                        .transition(.opacity)
                @unknown default:
                    Color.secondary.opacity(0.1)
                }
            }
            .frame(width: 86, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.semibold(size: 16))
                    .lineLimit(2)
                    .minimumScaleFactor(0.9)
                HStack(spacing: 8) {
                    Text(item.source)
                        .font(.regular(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Text(item.publishedRelative ?? "")
                        .font(.regular(size: 8))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Placeholder
    private var placeholderImage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
            Image(systemName: "photo")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview
#Preview("ArticleRow", traits: .portrait) {
    ArticleRow(
        item: HeadlineItemViewData(
            id: "1",
            title: "Apple Unveils Revolutionary New Technology",
            source: "Apple Newsroom",
            imageURL: URL(string: "https://via.placeholder.com/600x400"),
            publishedRelative: "2h",
            articleURL: URL(string: "https://example.com"),
            summary: "In a groundbreaking announcement, Apple has revealed its latest innovation that promises to transform the tech industry forever.",
            content: "This is the detailed content of the article..."
        )
    )
}
