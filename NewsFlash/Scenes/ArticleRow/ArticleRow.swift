//
//  ArticleRow.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import SwiftUI

struct ArticleRow: View {
    let article: Article
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: URL(string: article.image ?? "")) { phase in
                switch phase {
                case .empty:
                    ZStack { RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)); ProgressView() }
                case let .success(image):
                    image.resizable().scaledToFill()
                case .failure:
                    ZStack { RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.2)); Image(systemName: "photo") }
                @unknown default:
                    Color.secondary.opacity(0.1)
                }
            }
            .frame(width: 86, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(article.title)
                    .font(.semibold(size: 16))
                    .lineLimit(2)
                HStack(spacing: 8) {
                    Text(article.source.name ?? "—")
                        .font(.semibold(size: 14))
                        .foregroundStyle(.secondary)
                    Text(publishedText(article.publishedAt))
                        .font(.regular(size: 8))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    private func publishedText(_ date: Date?) -> String {
        guard let date else { return "" }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: date, relativeTo: .now)
    }
}
