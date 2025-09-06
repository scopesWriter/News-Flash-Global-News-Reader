//
//  NewsAPIClient.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

/// Contract for fetching news from a backend (GNews by default)
protocol NewsAPIClientProtocol {
    /// Fetch top headlines
    func topHeadlines(language: String, maximumLimit: Int, country: String?) async throws -> [Article]
    /// Search articles by free text
    func search(_ query: String, language: String, maximumLimit: Int) async throws -> [Article]
}
