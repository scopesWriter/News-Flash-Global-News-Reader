//
//  ArticleDetail.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import SwiftUI

struct ArticleDetail: View {
    let article: Article
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let urlString = article.image, let url = URL(string: urlString) {
                    AsyncImage(url: url) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        ZStack { Rectangle().fill(Color.gray.opacity(0.15)); ProgressView() }
                    }
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Text(article.title).font(.title2).bold()
                HStack(spacing: 12) {
                    Label(article.source.name ?? "—", systemImage: "newspaper")
                    if let date = article.publishedAt {
                        Text(date.formatted(date: .abbreviated, time: .shortened))
                    }
                }
                .foregroundStyle(.secondary)
                
                if let description = article.description, !description.isEmpty {
                    Text(description).font(.body)
                }
                if let content = article.content, !content.isEmpty {
                    Text(content).font(.body)
                }
                
                if let link = article.url, let url = URL(string: link) {
                    Link(destination: url) { Label("Read full story", systemImage: "safari") }
                }
            }
            .padding()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
