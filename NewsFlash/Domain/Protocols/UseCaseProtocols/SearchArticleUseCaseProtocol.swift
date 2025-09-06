//
//  SearchArticleUseCaseProtocol.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

/// Use case for searching articles by free-text query.
protocol SearchArticlesUseCaseProtocol {
    /// Executes the use case.
    /// - Parameters:
    ///   - query: Free text to search.
    ///   - language: Preferred language ISO-2 code (e.g. "en").
    ///   - maximumLimit: Max number of articles to fetch.
    func execute(query: String, language: String, maximumLimit: Int) async throws -> [Article]
}
