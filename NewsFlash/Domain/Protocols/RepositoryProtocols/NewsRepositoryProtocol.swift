//
//  NewsRepositoryProtocol.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

protocol NewsRepositoryProtocol {
    /// - Parameters:
    ///   - language: language description
    ///   - maximumLimit: maximumLimit description
    ///   - country: country description
    /// - Returns: array of articles
     func topHeadlines(
        language: String,
        maximumLimit: Int,
        country: String?
     ) async throws -> [Article]
    
    /// Used to search for selected trending topic
    /// - Parameters:
    ///   - query: value
    ///   - language: the current language
    ///   - maximumLimit: max fetched number of headlines
    /// - Returns: array of articles
     func search(
        _ query: String,
        language: String,
        maximumLimit: Int
     ) async throws -> [Article]
}
