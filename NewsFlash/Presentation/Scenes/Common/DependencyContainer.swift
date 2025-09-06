//
//  AppContainer.swift
//  NewsFlash
//  Created by Bishoy Badie on 04/08/2025.
//

// MARK: -  Refactor Note:
//  - Introduced a lightweight DI container to wire Data -> Domain (UseCases) -> Presentation.
//  - Centralizes object graph creation and simplifies previews/tests by allowing custom init.
// DependencyContainer is the application's central composition root.
// - It initializes and holds singletons for the Data layer (API client, repositories),
//   the Domain layer (use cases), and provides factory methods for the Presentation layer.
// - All ViewModels should be created through this container to ensure their dependencies
//   are injected consistently across the app.

import Foundation

final class DependencyContainer {
    /// Thread-safe singleton instance. Static `let` init is atomic in Swift.
    static let shared = DependencyContainer()

    // MARK: - Data Layer (immutable graph)
    let apiClient: NewsAPIClientProtocol
    let repository: NewsRepositoryProtocol

    // MARK: - Domain Layer (Use Cases)
    let topHeadlinesUseCase: TopHeadlinesUseCase
    let searchArticlesUseCase: SearchArticlesUseCase
    let headlinesMapper: HeadlinesViewDataMappingProtocol = HeadlinesViewDataMapper()
    let errorMapper: PresentationErrorMappingProtocol = PresentationErrorMapper()

    /// Default initializer builds the full object graph once.
    /// Using immutable `let` properties (no `lazy`) makes this thread-safe and predictable.
    private init() {
        self.apiClient = URLSessionAPIClient()
        self.repository = NewsRepository(apiClient: apiClient)
        self.topHeadlinesUseCase = TopHeadlinesUseCase(repository: repository)
        self.searchArticlesUseCase = SearchArticlesUseCase(repository: repository)
    }

    /// Test-friendly initializer to inject fakes or alternative implementations.
    /// If `repository` is not supplied, it will be composed from the provided `apiClient`.
    init(apiClient: NewsAPIClientProtocol, repository: NewsRepositoryProtocol? = nil) {
        self.apiClient = apiClient
        self.repository = repository ?? NewsRepository(apiClient: apiClient)
        self.topHeadlinesUseCase = TopHeadlinesUseCase(repository: self.repository)
        self.searchArticlesUseCase = SearchArticlesUseCase(repository: self.repository)
    }

    // MARK: - Presentation factories
    /// We scope only this factory to the main actor because ViewModels are `@MainActor`-isolated.
    /// Keeping the container non-main-actor avoids over-serializing data-layer work.
    @MainActor
    func makeHeadlinesViewModel() -> HeadlinesViewModel {
        HeadlinesViewModel(
            getTopHeadlines: topHeadlinesUseCase,
            searchArticles: searchArticlesUseCase,
            mapper: headlinesMapper,
            errorMapper: errorMapper
        )
    }

    /// Factory for ArticleDetailsViewModel
    /// - Parameter item: Presentation model for the selected article
    /// - Returns: A `@MainActor`-isolated view model ready for binding to `ArticleDetails`
    @MainActor
    func makeArticleDetailsViewModel(item: HeadlineItemViewData) -> ArticleDetailsViewModel {
        ArticleDetailsViewModel(item: item)
    }
}

