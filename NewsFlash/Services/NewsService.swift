//
//  NewsService.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import Foundation

/// Abstraction to supply the API token (so we can swap sources for tests/CI)
protocol TokenProvider {
    var token: String { get }
}

/// Default token provider that reads from Info.plist (key: `GNEWS_API_KEY`)
struct InfoPlistTokenProvider: TokenProvider {
    var token: String {
        (Bundle.main.object(forInfoDictionaryKey: "GNEWS_API_KEY") as? String) ?? ""
    }
}

// MARK: - Protocol

/// Contract for fetching news from a backend (GNews by default)
protocol NewsServiceProtocol {
    /// Fetch top headlines
    func topHeadlines(language: String, maximumLimit: Int, country: String?) async throws -> [Article]
    /// Search articles by free text
    func search(_ query: String, language: String, maximumLimit: Int) async throws -> [Article]
}

enum GNewsAPI {
    static let base = URL(string: "https://gnews.io/api/v4")!
}

// MARK: - Routing

/// Service-specific errors
enum NewsServiceError: Error {
    case missingAPIKey
    case invalidURL
}

/// Endpoints supported by the service
private enum Endpoint: String {
    case topHeadlines = "top-headlines"
    case search = "search"
}

// MARK: - Service

final class NewsService: NewsServiceProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: URL
    private let tokenProvider: TokenProvider
    
    init(session: URLSession = .shared,
         baseURL: URL = GNewsAPI.base,
         tokenProvider: TokenProvider = InfoPlistTokenProvider()) {
        self.session = session
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    private func makeComponents(_ endpoint: Endpoint, items: [URLQueryItem]) throws -> URLComponents {
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
    
    private func fetchArticles(_ endpoint: Endpoint, items: [URLQueryItem]) async throws -> [Article] {
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
            .init(name: "token", value: token)
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
            .init(name: "token", value: token)
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
