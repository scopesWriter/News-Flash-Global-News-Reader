//
//  HeadlinesViewModel.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import Combine
import SwiftUI

@MainActor
final class HeadlinesViewModel: ObservableObject {
    enum State: Equatable {
        case idle, loading, loaded, error(String)
    }
    
    enum HeadlinesError: Error, LocalizedError {
        case missingAPIKey
        case rateLimited
        case generic(Error)
        
        var errorDescription: String? {
            switch self {
            case .missingAPIKey:
                return "Missing or invalid API key. Add `GNEWS_API_KEY` to Info.plist."
            case .rateLimited:
                return "Rate limit reached. Please wait and try again."
            case .generic(let error):
                return "Failed to load news. \(error.localizedDescription)"
            }
        }
    }

    @Published private(set) var articles: [Article] = []
    @Published private(set) var state: State = .idle
    @Published var query: String = ""

    private let service: NewsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(service: NewsServiceProtocol = NewsService()) {
        self.service = service

        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(450), scheduler: RunLoop.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                Task { await self.perform(query: text) }
            }
            .store(in: &cancellables)
    }

    func refresh() async {
        await perform(query: query)
    }

    private func set(_ newState: State) {
        withAnimation {
            state = newState
        }
    }

    private func perform(query: String) async {
        set(.loading)
        do {
            let result: [Article]
            let lang = Locale.preferredLanguages.first?.prefix(2).description ?? "en"
            if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                result = try await service.topHeadlines(language: lang, maximumLimit: 30, country: nil)
            } else {
                result = try await service.search(query, language: lang, maximumLimit: 30)
            }
            articles = result
            set(.loaded)
        } catch {
            let headlinesError: HeadlinesError
            if let urlError = error as? URLError {
                switch urlError.code {
                case .userAuthenticationRequired:
                    headlinesError = .missingAPIKey
                case .dataNotAllowed:
                    headlinesError = .rateLimited
                default:
                    headlinesError = .generic(error)
                }
            } else {
                headlinesError = .generic(error)
            }
            set(.error(headlinesError.errorDescription ?? "An unknown error occurred."))
        }
    }
}
