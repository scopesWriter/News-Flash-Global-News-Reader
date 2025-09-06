//
//  ApiClient.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

// Moved TokenProvider to TokenProvider.swift

// MARK: - Protocol

// Protocol is now defined in Domain layer: Domain/Protocols/DataSourceProtocols/NewsAPIClient.swift

// Moved base URL config to APIConfig.swift

// MARK: - Routing

// Errors moved to NewsServiceError.swift

// Endpoints moved to Endpoints.swift as APIEndpoint

// MARK: - Service

final class URLSessionAPIClient: NewsAPIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: URL
    private let tokenProvider: TokenProvider
    
    init(
        session: URLSession = .shared,
        baseURL: URL = GNewsAPIConfig.baseURL,
        tokenProvider: TokenProvider = InfoPlistTokenProvider()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }
    
    private func makeComponents(_ endpoint: APIEndpoint, items: [URLQueryItem]) throws -> URLComponents {
        var components = URLComponents(url: baseURL.appendingPathComponent(endpoint.rawValue), resolvingAgainstBaseURL: false)
        guard components != nil else { throw NewsServiceError.invalidURL }
        components!.queryItems = items
        return components!
    }
    
    private func tokenOrThrow() throws -> String {
        let token = tokenProvider.token
        guard !token.isEmpty else { throw NewsServiceError.missingAPIKey }
        return token
    }
    
    private func fetchArticles(_ endpoint: APIEndpoint, items: [URLQueryItem]) async throws -> [Article] {
        let components = try makeComponents(endpoint, items: items)
        guard let url = components.url else { throw NewsServiceError.invalidURL }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        let (data, response) = try await session.data(for: request)
        try check(response)
        return try decoder.decode(ArticlesResponse.self, from: data).articles
    }
    
    func topHeadlines(
        language: String = Locale.preferredLanguages.first?.prefix(2).description ?? "en",
        maximumLimit: Int = 30,
        country: String? = nil
    ) async throws -> [Article] {
        let token = try tokenOrThrow()
        var query: [URLQueryItem] = [
            .init(name: "lang", value: language),
            .init(name: "max", value: String(maximumLimit)),
            .init(name: "token", value: token),
        ]
        if let country { query.append(.init(name: "country", value: country)) }
        return try await fetchArticles(.topHeadlines, items: query)
    }
    
    func search(
        _ query: String,
        language: String = Locale.preferredLanguages.first?.prefix(2).description ?? "en",
        maximumLimit: Int = 10
    ) async throws -> [Article] {
        let token = try tokenOrThrow()
        let queryItems: [URLQueryItem] = [
            .init(name: "q", value: query),
            .init(name: "lang", value: language),
            .init(name: "max", value: String(maximumLimit)),
            .init(name: "token", value: token),
        ]
        return try await fetchArticles(.search, items: queryItems)
    }
    
    /// Validates HTTP status codes and maps them to URLError where appropriate.
    private func check(_ response: URLResponse) throws {
        guard let http = response as? HTTPURLResponse else { return }
        // Print statusCode and response for debugging
        print("Response: \(http)")
        print("Status Code: \(http.statusCode)")
        
        switch http.statusCode {
        case 200 ... 299: return
        case 401, 403: throw URLError(.userAuthenticationRequired)
        case 429: throw URLError(.dataNotAllowed)
        default: throw URLError(.badServerResponse)
        }
    }
}
