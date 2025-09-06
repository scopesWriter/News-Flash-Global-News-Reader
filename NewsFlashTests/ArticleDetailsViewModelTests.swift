//
//  ArticleDetailsViewModelTests.swift
//  NewsFlashTests
//
//  Created by Bishoy Badie on 06/09/2025.
//

import XCTest
@testable import NewsFlash

@MainActor
final class ArticleDetailsViewModelTests: XCTestCase {

    func test_properties_reflectItem() {
        // Arrange: build presentation-only item (no Domain coupling)
        let item = HeadlineItemViewData(
            id: "id-1",
            title: "Breaking Swift News",
            source: "NewsFlash",
            imageURL: URL(string: "https://example.com/hero.png"),
            publishedRelative: "2h",
            articleURL: URL(string: "https://example.com/post"),
            summary: "Apple unveils…",
            content: "Full article text…"
        )

        let sut = ArticleDetailsViewModel(item: item)

        // Assert
        XCTAssertEqual(sut.title, "Breaking Swift News")
        XCTAssertEqual(sut.source, "NewsFlash")
        XCTAssertEqual(sut.imageURL?.absoluteString, "https://example.com/hero.png")
        XCTAssertEqual(sut.publishedRelative, "2h")
        XCTAssertEqual(sut.summary, "Apple unveils…")
        XCTAssertEqual(sut.content, "Full article text…")
        XCTAssertEqual(sut.articleURL?.absoluteString, "https://example.com/post")
    }

    func test_optionalURL_isNil_whenNotProvided() {
        // Arrange: no URL/summary/content
        let item = HeadlineItemViewData(
            id: "id-2",
            title: "Local Story",
            source: "Local Source",
            imageURL: nil,
            publishedRelative: nil,
            articleURL: nil,
            summary: nil,
            content: nil
        )
        
        let sut = ArticleDetailsViewModel(item: item)

        // Assert
        XCTAssertNil(sut.imageURL)
        XCTAssertNil(sut.publishedRelative)
        XCTAssertNil(sut.articleURL)
        XCTAssertNil(sut.summary)
        XCTAssertNil(sut.content)
    }

    func test_shareTapped_doesNotCrash() async {
        // Arrange
        let item = HeadlineItemViewData(
            id: "id-3",
            title: "Shareable",
            source: "Source",
            imageURL: nil,
            publishedRelative: nil,
            articleURL: URL(string: "https://share.me"),
            summary: nil,
            content: nil
        )
        let viewModel = ArticleDetailsViewModel(item: item)

        // Act
        viewModel.shareTapped()

        // Assert: nothing to assert yet; use when you inject a logging use case.
        XCTAssertTrue(true)
    }
}
