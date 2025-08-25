//
//  HeadlinesViewModelTests.swift
//  NewsFlashTests
//
//  Created by Bishoy Badie on 26/08/2025.
//

import XCTest
@testable import NewsFlash

@MainActor
final class HeadlinesViewModelTests: XCTestCase {
    
    func testRefreshLoadsTopHeadlinesWhenQueryEmpty() async {
        let svc = MockNewsService(
            headlines: [Article(
                title: "A",
                description: nil,
                content: nil,
                url: nil,
                image: nil,
                publishedAt: nil,
                source: .init(
                    name: "X",
                    url: nil
                )
            )],
            search: []
        )
        let vm = HeadlinesViewModel(service: svc)
        
        await vm.refresh()
        
        XCTAssertEqual(vmState(vm), "loaded")
        XCTAssertEqual(vm.articles.count, 1)
        XCTAssertEqual(vm.articles.first?.title, "A")
    }
    
    func testTypingQueryTriggersSearch() async {
        let svc = MockNewsService(
            headlines: [],
            search: [Article(
                title: "Searched",
                description: nil,
                content: nil,
                url: nil,
                image: nil,
                publishedAt: nil,
                source: .init(
                    name: "Y",
                    url: nil
                )
            )]
        )
        let vm = HeadlinesViewModel(service: svc)
        
        vm.query = "apple"
        // Allow debounce to fire (450ms) + small buffer
        try? await Task.sleep(nanoseconds: 600_000_000)
        
        XCTAssertEqual(vmState(vm), "loaded")
        XCTAssertEqual(vm.articles.first?.title, "Searched")
    }
    
    func testErrorMissingAPIKeySurfaced() async {
        let svc = MockNewsService(error: URLError(.userAuthenticationRequired))
        let vm = HeadlinesViewModel(service: svc)
        
        await vm.refresh()
        
        XCTAssertTrue(vmState(vm).contains("error"))
    }
    
    // Helper to peek state (avoid exposing internal enum outside tests)
    private func vmState(_ vm: HeadlinesViewModel) -> String {
        Mirror(reflecting: vm).children.first { $0.label == "state" }?.value as? String ?? "\(vm)"
    }
}

// MARK: - Mock
struct MockNewsService: NewsServiceProtocol {
    var headlines: [Article] = []
    var search: [Article] = []
    var error: Error?
    
    func topHeadlines(language: String, maximumLimit: Int, country: String?) async throws -> [Article] {
        if let error { throw error }
        return headlines
    }
    func search(_ query: String, language: String, maximumLimit: Int) async throws -> [Article] {
        if let error { throw error }
        return self.search
    }
}
