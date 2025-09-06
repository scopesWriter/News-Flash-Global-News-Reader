//
//  NewsRepository.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

final class NewsRepository: NewsRepositoryProtocol {
    private let apiClient: NewsAPIClientProtocol

    init(apiClient: NewsAPIClientProtocol = URLSessionAPIClient()) {
        self.apiClient = apiClient
    }
    
    func topHeadlines(language: String, maximumLimit: Int, country: String?) async throws -> [Article] {
        do {
            return try await apiClient.topHeadlines(language: language, maximumLimit: maximumLimit, country: country)
        } catch {
            throw mapToDomainError(error)
        }
    }

    func search(_ query: String, language: String, maximumLimit: Int) async throws -> [Article] {
        do {
            return try await apiClient.search(query, language: language, maximumLimit: maximumLimit)
        } catch {
            throw mapToDomainError(error)
        }
    }

    private func mapToDomainError(_ error: Error) -> DomainError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .userAuthenticationRequired, .userCancelledAuthentication:
                return .authRequired
            case .dataNotAllowed:
                return .rateLimited
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .badServerResponse, .cannotParseResponse:
                return .invalidResponse
            default:
                return .unknown
            }
        }
        if error is DecodingError {
            return .decoding
        }
        return .unknown
    }
}

