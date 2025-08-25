//
//  ArticlesDecodingTests.swift
//  NewsFlashTests
//
//  Created by Bishoy Badie on 26/08/2025.
//

import XCTest
@testable import NewsFlash

final class ArticlesDecodingTests: XCTestCase {

    func testDecodeArticlesResponse() throws {
        let json = """
        {
          "totalArticles": 2,
          "articles": [
            {
              "title": "First",
              "description": "desc",
              "content": "body",
              "url": "https://example.com/1",
              "image": "https://img.com/1.jpg",
              "publishedAt": "2024-03-15T18:22:00Z",
              "source": {"name": "BBC", "url": "https://bbc.com"}
            },
            {
              "title": "Second",
              "description": null,
              "content": null,
              "url": null,
              "image": null,
              "publishedAt": "2024-03-16T10:00:00Z",
              "source": {"name": null, "url": null}
            }
          ]
        }
        """.data(using: .utf8)!

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let decoded = try decoder.decode(ArticlesResponse.self, from: json)
        XCTAssertEqual(decoded.totalArticles, 2)
        XCTAssertEqual(decoded.articles.count, 2)
        XCTAssertEqual(decoded.articles[0].title, "First")
        XCTAssertEqual(decoded.articles[0].source.name, "BBC")
        XCTAssertNotNil(decoded.articles[0].publishedAt)
        XCTAssertNotNil(decoded.articles[1].publishedAt)
    }
}
