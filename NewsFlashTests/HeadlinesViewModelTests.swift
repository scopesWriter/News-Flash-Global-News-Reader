//
//  HeadlinesViewModelTests.swift
//  NewsFlashTests
//
//  Created by Bishoy Badie on 26/08/2025.
//

import XCTest
@testable import NewsFlash

/// VM tests
/// - State transitions (idle → loading → loaded / error)
/// - Correct wiring to use cases (top headlines vs. search)
/// - Mapping (Domain Article → Presentation ViewData)
/// - Error mapping (DomainError → PresentationError)

@MainActor
final class HeadlinesViewModelTests: XCTestCase {

    // MARK: - Happy Scenario: initial load

    func test_loadInitialData_success_setsLoadedStateWithItems() async {
        // Arrange: a use case that returns 2 domain articles
        let articles = [
            Article(
                title: "A",
                description: "descA",
                content: "contentA",
                url: "https://a.com",
                image: nil,
                publishedAt: nil,
                source: .init(name: "SrcA", url: nil)
            ),
            Article(
                title: "B",
                description: "descB",
                content: "contentB",
                url: "https://b.com",
                image: nil,
                publishedAt: nil,
                source: .init(name: "SrcB", url: nil)
            )
        ]
        let topUseCase = TopUseCaseStub { _,_,_ in articles }
        let searchUseCase = SearchUseCaseStub { _,_,_ in XCTFail("search should not be called on initial load"); return [] }

        // Mapper returns ViewData
        let mapper = HeadlinesMapperStub { article in
            HeadlineItemViewData(
                id: article.title,
                title: article.title,
                source: article.source.name ?? "—",
                imageURL: nil,
                publishedRelative: nil,
                articleURL: URL(string: article.url ?? ""),
                summary: article.description,
                content: article.content
            )
        }
        let errorMapper: PresentationErrorMappingProtocol = PresentationErrorMapper()

        let viewModel = HeadlinesViewModel(
            getTopHeadlines: topUseCase,
            searchArticles: searchUseCase,
            mapper: mapper,
            errorMapper: errorMapper
        )

        // Act
        await viewModel.loadInitialData()

        // Assert: loaded with 2 mapped items
        guard case let .loaded(items) = viewModel.state else {
            XCTFail("Expected loaded state, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(items.map(\.id), ["A", "B"])
        XCTAssertEqual(items.first?.summary, "descA")
        XCTAssertEqual(items.last?.content, "contentB")
    }

    // MARK: - Error path: initial load

    func test_loadInitialData_failure_mapsToPresentationError() async {
        // Arrange: top headlines throws a domain error
        let topUseCase = TopUseCaseStub { _,_,_ in throw DomainError.networkUnavailable }
        let searchUseCase = SearchUseCaseStub { _,_,_ in [] }
        let mapper: HeadlinesViewDataMappingProtocol = HeadlinesViewDataMapper()
        let errorMapper: PresentationErrorMappingProtocol = PresentationErrorMapper()

        // We can use the real mapper; it won't be called on failure
        let viewModel = HeadlinesViewModel(
            getTopHeadlines: topUseCase,
            searchArticles: searchUseCase,
            mapper: mapper,
            errorMapper: errorMapper
        )

        // Act
        await viewModel.loadInitialData()

        // Assert: error is PresentationError.networkUnavailable
        guard case let .error(err) = viewModel.state else {
            XCTFail("Expected error state, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(err, .networkUnavailable)
    }

    // MARK: - Search path uses SearchArticlesUseCase

    func test_refresh_withQuery_callsSearchUseCase() async {
        // Arrange
        var searchCalled = false
        let topUseCase = TopUseCaseStub { _,_,_ in [] }
        let searchUseCase = SearchUseCaseStub { q,_,_ in
            searchCalled = true
            XCTAssertEqual(q, "swift")
            return [
                Article(title: "S", description: nil, content: nil, url: nil, image: nil, publishedAt: nil, source: .init(name: "Src", url: nil))
            ]
        }
        let mapper: HeadlinesViewDataMappingProtocol = HeadlinesViewDataMapper()
        let errorMapper: PresentationErrorMappingProtocol = PresentationErrorMapper()
        
        let viewModel = HeadlinesViewModel(
            getTopHeadlines: topUseCase,
            searchArticles: searchUseCase,
            mapper: mapper,
            errorMapper: errorMapper
        )

        viewModel.query = "swift"

        // Act: refresh bypasses debounce and goes straight to performSearch
        await viewModel.refresh()

        // Assert
        XCTAssertTrue(searchCalled, "Expected search use case to be called on refresh when query is non-empty")
        guard case let .loaded(items) = viewModel.state else {
            XCTFail("Expected loaded state, got \(viewModel.state)")
            return
        }
        XCTAssertEqual(items.first?.title, "S")
    }

    // MARK: - Debounced search (slow test; optional)

    func test_queryChanged_debouncesBeforeSearching() async {
        // NOTE: This test respects VM's hard-coded debounceInterval = 0.5s.
        // If you adopt injectible config (recommended), set a tiny debounce in tests instead.
        let expectation = expectation(description: "debounced search completes")

        var events: [String] = []
        let topUseCase = TopUseCaseStub { _,_,_ in [] }
        let searchUseCase = SearchUseCaseStub { q,_,_ in
            events.append(q)
            return []
        }
        let mapper: HeadlinesViewDataMappingProtocol = HeadlinesViewDataMapper()
        let errorMapper: PresentationErrorMappingProtocol = PresentationErrorMapper()
        
        let viewModel = HeadlinesViewModel(
            getTopHeadlines: topUseCase,
            searchArticles: searchUseCase,
            mapper: mapper,
            errorMapper: errorMapper
        )

        // Act: type quickly; only the last query should be used
        viewModel.queryChanged("s")
        viewModel.queryChanged("sw")
        viewModel.queryChanged("swi")
        viewModel.queryChanged("swift")

        // Wait (debounce 0.5s + buffer)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 1.0)

        // Assert: only one search executed with final query
        XCTAssertEqual(events, ["swift"])
    }
}

/// Top headlines use case stub
private struct TopUseCaseStub: TopHeadlinesUseCaseProtocol {
    let block: (_ lang: String, _ max: Int, _ country: String?) async throws -> [Article]
    func execute(language: String, maximumLimit: Int, country: String?) async throws -> [Article] {
        try await block(language, maximumLimit, country)
    }
}

/// Search use case stub
private struct SearchUseCaseStub: SearchArticlesUseCaseProtocol {
    let block: (_ query: String, _ lang: String, _ max: Int) async throws -> [Article]
    func execute(query: String, language: String, maximumLimit: Int) async throws -> [Article] {
        try await block(query, language, maximumLimit)
    }
}

/// Mapper stub to control ViewData output deterministically
private struct HeadlinesMapperStub: HeadlinesViewDataMappingProtocol {
    let block: (Article) -> HeadlineItemViewData
    func map(_ a: Article) -> HeadlineItemViewData {
        block(a)
    }
}
