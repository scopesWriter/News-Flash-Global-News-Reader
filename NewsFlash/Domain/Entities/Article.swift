//
//  Article.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import Foundation

// Identifiable: Provides a stable id for SwiftUI List/ForEach
// Decodable: Allows JSON parsing into Article
// Hashable: Allows comparison, used in sets/dictionaries, and SwiftUI diffing algorithm
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
    var idForList: String {
        url ?? id
    }
}
