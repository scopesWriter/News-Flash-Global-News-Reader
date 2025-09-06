//
//  TopHeadlinesUseCaseProtocol.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

/// Use case for fetching top headlines.
/// This abstracts application business logic away from presentation and data layers.
protocol TopHeadlinesUseCaseProtocol {
    /// Executes the use case.
    /// - Parameters:
    ///   - language: Preferred language ISO-2 code (e.g. "en").
    ///   - maximumLimit: Max number of articles to fetch.
    ///   - country: Optional country filter.
    func execute(
        language: String,
        maximumLimit: Int,
        country: String?
    ) async throws -> [Article]
}
