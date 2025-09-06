//
//  HeadlinesViewModel.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import Foundation

//  MARK: - Refactor Note (Clean Architecture):

//  - ViewModel no longer depends on NewsRepositoryProtocol directly.
//  - It now depends on two UseCases: GetTopHeadlinesUseCase and SearchArticlesUseCase.
//  - This keeps UI independent from data source and simplifies unit testing via use case mocks.

@MainActor
final class HeadlinesViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var state: ScreenState = .idle
    @Published var query: String = ""
    
    // MARK: - Public Properties
    
    let topics: [Topic] = Topic.allCases
    
    var emptyDescriptionMessage: LocalizedStringResource {
        if query.isEmpty { return "no_articles_available" }
        if let topic = selectedTopic {
            return "no_articles_found_with_topic \(String(localized: topic.localizedName))"
        } else {
            // free text typed by the user; show as-is
            return "no_articles_found_with_topic \(query)"
        }
    }
    
    var normalizedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
    
    var selectedTopic: Topic? {
        Topic(rawValue: normalizedQuery)
    }
    
    // MARK: - Private Properties
    
    private let getTopHeadlines: TopHeadlinesUseCaseProtocol
    private let searchArticles: SearchArticlesUseCaseProtocol
    private let mapper: HeadlinesViewDataMappingProtocol
    private let errorMapper: PresentationErrorMappingProtocol
    
    private let debouncer = Debouncer()
    private let debounceInterval: TimeInterval = 0.5
    private let maxArticles = 50
    
    // MARK: - Debouncer (single concurrency model)
    actor Debouncer {
        private var task: Task<Void, Never>?
        func run(after seconds: TimeInterval, _ block: @escaping () async -> Void) {
            task?.cancel()
            task = Task {
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                guard !Task.isCancelled else { return }
                await block()
            }
        }
        func cancel() {
            task?.cancel()
            task = nil
        }
    }
    
    // MARK: - Init
    
    init(
        getTopHeadlines: TopHeadlinesUseCaseProtocol,
        searchArticles: SearchArticlesUseCaseProtocol,
        mapper: HeadlinesViewDataMappingProtocol = HeadlinesViewDataMapper(),
        errorMapper: PresentationErrorMappingProtocol = PresentationErrorMapper()
    ) {
        self.getTopHeadlines = getTopHeadlines
        self.searchArticles = searchArticles
        self.mapper = mapper
        self.errorMapper = errorMapper
    }
    
    // MARK: - Deinit
    
    deinit {
        let debouncer = self.debouncer
        Task.detached { [debouncer] in
            await debouncer.cancel()
        }
    }
    
    // MARK: - Public Methods
    
    func loadInitialData() async {
        guard case .idle = state else { return }
        state = .loading(.initial)
        do {
            let language = getPreferredLanguage()
            let result = try await getTopHeadlines.execute(language: language, maximumLimit: maxArticles, country: nil)
            state = .loaded(result.map(toViewData))
        } catch {
            state = .error(errorMapper.map(error))
        }
    }
    
    func refresh() async {
        await performSearch(query: query, kind: .refresh)
    }
    
    func queryChanged(_ text: String) {
        Task { [debounceInterval, weak self] in
            guard let self else { return }
            await self.debouncer.run(after: debounceInterval) { [weak self] in
                guard let self else { return }
                await self.performSearch(query: text, kind: .search)
            }
        }
    }
    
    func isTopicSelected(_ topic: Topic) -> Bool {
        normalizedQuery == topic.rawValue.lowercased()
    }
    
    func toggleTopic(_ topic: Topic) {
        query = isTopicSelected(topic) ? "" : String(localized: topic.localizedName)
    }
    
    // MARK: - Private Methods
    
    private func performSearch(query: String, kind: LoadKind = .search) async {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        state = .loading(kind)
        do {
            let result = try await fetchArticles(query: trimmedQuery)
            state = .loaded(result.map(toViewData))
        } catch {
            state = .error(errorMapper.map(error))
        }
    }
    
    private func fetchArticles(query: String) async throws -> [Article] {
        let language = getPreferredLanguage()
        
        if query.isEmpty {
            return try await getTopHeadlines.execute(
                language: language,
                maximumLimit: maxArticles,
                country: nil
            )
        } else {
            return try await searchArticles.execute(
                query: query,
                language: language,
                maximumLimit: maxArticles
            )
        }
    }
    
    private func toViewData(_ article: Article) -> HeadlineItemViewData {
        mapper.map(article)
    }
    
    private func getPreferredLanguage() -> String {
        return Locale.preferredLanguages.first?.prefix(2).description ?? "en"
    }
}
