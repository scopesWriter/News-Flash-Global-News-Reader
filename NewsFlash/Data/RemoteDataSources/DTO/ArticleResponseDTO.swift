//
//  ArticleResponseDTO.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

struct ArticlesResponse: Decodable {
    let totalArticles: Int?
    let articles: [Article]
}
