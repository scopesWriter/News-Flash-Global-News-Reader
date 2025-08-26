//
//  HeadlinesViewModel.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import Combine
import Foundation

@MainActor
final class HeadlinesViewModel: ObservableObject {
    
    // MARK: - Types
    
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }
    
    enum HeadlinesError: Error, LocalizedError {
        case missingAPIKey
        case rateLimited
        case networkUnavailable
        case invalidResponse
        case generic(Error)
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Missing or invalid API key. Please check your configuration."
            case .rateLimited:
                return "Too many requests. Please wait a moment and try again."
            case .networkUnavailable:
                return "No internet connection. Please check your network settings."
            case .invalidResponse:
                return "Invalid response from server. Please try again."
            case .generic(let error):
                return error.localizedDescription
            }
        }
    }
    
    // MARK: - Published Properties
    
    @Published private(set) var articles: [Article] = []
    @Published private(set) var state: State = .idle
    @Published var query: String = ""
    
    // MARK: - Public Properties
    
    let quickTopics: [String] = [
        NSLocalizedString("technology", comment: "Technology"),
        NSLocalizedString("apple", comment: "Apple"),
        NSLocalizedString("ai", comment: "AI"),
        NSLocalizedString("ios", comment: "iOS"),
        NSLocalizedString("swift", comment: "Swift"),
        NSLocalizedString("business", comment: "Business"),
        NSLocalizedString("science", comment: "Science"),
        NSLocalizedString("health", comment: "Health"),
        NSLocalizedString("sports", comment: "Sports"),
        NSLocalizedString("entertainment", comment: "Entertainment"),
        NSLocalizedString("politics", comment: "Politics"),
        NSLocalizedString("climate", comment: "Climate")
    ]
    
    // MARK: - Private Properties
    
    private let service: NewsServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var searchTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval = 0.5
    private let maxArticles = 50
    
    // MARK: - Initialization
    
    init(service: NewsServiceProtocol = NewsService()) {
        self.service = service
        setupSearchBinding()
    }
    
    deinit {
        searchTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() async {
        guard state == .idle else { return }
        
        print("🚀 Loading initial data...")
        setState(.loading)
        
        do {
            let language = getPreferredLanguage()
            let result = try await service.topHeadlines(
                language: language,
                maximumLimit: maxArticles,
                country: nil
            )
            
            print("📰 Initial load: Fetched \(result.count) articles")
            articles = result
            setState(.loaded)
            
        } catch {
            print("❌ Initial load error: \(error)")
            let headlinesError = mapError(error)
            setState(.error(headlinesError.errorDescription ?? "An unexpected error occurred."))
        }
    }
    
    func refresh() async {
        print("🔄 Refreshing...")
        await performSearch(query: query, isRefresh: true)
    }
    
    // MARK: - Private Methods
    
    private func setupSearchBinding() {
        $query
            .removeDuplicates()
            .debounce(for: .seconds(debounceInterval), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText in
                self?.handleQueryChange(searchText)
            }
            .store(in: &cancellables)
    }
    
    private func handleQueryChange(_ searchText: String) {
        // Cancel previous search task
        searchTask?.cancel()
        
        // Don't search immediately on app launch if query is empty
        guard state != .idle else { return }
        
        // Create new search task
        searchTask = Task { [weak self] in
            guard !Task.isCancelled else { return }
            await self?.performSearch(query: searchText)
        }
    }
    
    private func performSearch(query: String, isRefresh: Bool = false) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Don't show loading for refresh when we already have content
        if !isRefresh || articles.isEmpty {
            setState(.loading)
        }
        
        do {
            let result = try await fetchArticles(query: trimmedQuery)
            
            guard !Task.isCancelled else { return }
            
            // Debug logging
            print("📰 Fetched \(result.count) articles for query: '\(trimmedQuery.isEmpty ? "top headlines" : trimmedQuery)'")
            
            articles = result
            setState(.loaded)
            
        } catch {
            guard !Task.isCancelled else { return }
            
            // Debug logging
            print("❌ Error fetching articles: \(error)")
            
            let headlinesError = mapError(error)
            setState(.error(headlinesError.errorDescription ?? "An unexpected error occurred."))
        }
    }
    
    private func fetchArticles(query: String) async throws -> [Article] {
        let language = getPreferredLanguage()
        
        if query.isEmpty {
            return try await service.topHeadlines(
                language: language,
                maximumLimit: maxArticles,
                country: nil
            )
        } else {
            return try await service.search(
                query,
                language: language,
                maximumLimit: maxArticles
            )
        }
    }
    
    private func getPreferredLanguage() -> String {
        return Locale.preferredLanguages.first?.prefix(2).description ?? "en"
    }
    
    private func getCountryCode() -> String? {
        return Locale.current.region?.identifier.lowercased()
    }
    
    private func mapError(_ error: Error) -> HeadlinesError {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .userAuthenticationRequired, .userCancelledAuthentication:
                return .missingAPIKey
            case .dataNotAllowed:
                return .rateLimited
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .badServerResponse, .cannotParseResponse:
                return .invalidResponse
            default:
                return .generic(error)
            }
        } else {
            return .generic(error)
        }
    }
    
    private func setState(_ newState: State) {
        guard state != newState else { return }
        state = newState
    }
}
