//
//  Article.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import Foundation

struct Article: Identifiable, Decodable, Hashable {
    var id: String {
        url ?? UUID().uuidString
    }
    
    let title: String
    let description: String?
    let content: String?
    let url: String?
    let image: String?
    let publishedAt: Date?
    let source: Source
    
    struct Source: Decodable, Hashable {
        let name: String?
        let url: String?
    }
    
    enum CodingKeys: String, CodingKey {
        case title, description, content, url, image, publishedAt, source
    }
}

// Convenience for List IDs when url is nil
extension Article {
    var _idForList: String {
        url ?? id
    }
}

struct ArticlesResponse: Decodable {
    let totalArticles: Int?
    let articles: [Article]
}
