//
//  URLSessionAPIClientTests.swift
//  NewsFlashTests
//
//  Created by Bishoy Badie on 06/09/2025.
//

import XCTest
@testable import NewsFlash

// MARK: - Test Doubles

/// Intercepts URLSession requests so we can assert on them and return canned responses.
final class StubURLProtocol: URLProtocol {
    typealias Handler = (URLRequest) throws -> (HTTPURLResponse, Data)

    static var requestHandler: Handler?
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        do {
            Self.lastRequest = request
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { /* no-op */ }
}

/// Token provider we can control in tests.
struct TestTokenProvider: TokenProvider {
    let token: String
}

/// Convenience to build a URLSession that uses StubURLProtocol.
private func makeStubbedSession() -> URLSession {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    return URLSession(configuration: config)
}

// MARK: - Tests

final class URLSessionAPIClientTests: XCTestCase {

    private var session: URLSession!
    private var baseURL: URL!

    override func setUp() {
        super.setUp()
        session = makeStubbedSession()
        baseURL = GNewsAPIConfig.baseURL // your app’s base URL
        StubURLProtocol.requestHandler = nil
        StubURLProtocol.lastRequest = nil
    }

    override func tearDown() {
        StubURLProtocol.requestHandler = nil
        StubURLProtocol.lastRequest = nil
        session = nil
        baseURL = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeClient(token: String = "TEST_TOKEN") -> URLSessionAPIClient {
        URLSessionAPIClient(
            session: session,
            baseURL: baseURL,
            tokenProvider: TestTokenProvider(token: token)
        )
    }

    private func ok(_ url: URL, body: Data) -> (HTTPURLResponse, Data) {
        (HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, body)
    }

    private func response(_ url: URL, status: Int, body: Data = Data()) -> (HTTPURLResponse, Data) {
        (HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!, body)
    }

    // MARK: - Request formation

    func test_topHeadlines_buildsCorrectPathAndQuery() async throws {
        // Arrange
        let client = makeClient()
        let lang = "en"
        let max = 30
        let country = "us"

        StubURLProtocol.requestHandler = { req in
            // Assert on the constructed URL
            guard let url = req.url, let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                XCTFail("Invalid URL")
                throw URLError(.badURL)
            }
            XCTAssertTrue(url.absoluteString.contains("/\(APIEndpoint.topHeadlines.rawValue)"),
                          "Path should include endpoint: \(APIEndpoint.topHeadlines.rawValue)")

            let items = comps.queryItems ?? []
            // Ensure required query params are present
            XCTAssertTrue(items.contains(.init(name: "lang", value: lang)))
            XCTAssertTrue(items.contains(.init(name: "max", value: String(max))))
            XCTAssertTrue(items.contains { $0.name == "token" && $0.value?.isEmpty == false })
            XCTAssertTrue(items.contains(.init(name: "country", value: country)))

            // Return a minimal valid JSON payload.
            let body = """
            {"articles":[{"title":"A","description":null,"content":null,"url":"https://a.com","image":null,"publishedAt":null,"source":{"name":"Src","url":null}}]}
            """.data(using: .utf8)!
            return self.ok(url, body: body)
        }

        // Act
        _ = try await client.topHeadlines(language: lang, maximumLimit: max, country: country)

        // Additionally verify HTTP method & cache policy
        let req = try XCTUnwrap(StubURLProtocol.lastRequest)
        XCTAssertEqual(req.httpMethod, "GET")
        XCTAssertEqual(req.cachePolicy, .reloadIgnoringLocalCacheData)
    }

    func test_search_buildsCorrectQuery_withQParam() async throws {
        // Arrange
        let client = makeClient()
        let q = "swift"
        let lang = "en"
        let max = 10

        StubURLProtocol.requestHandler = { req in
            guard let url = req.url, let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
                XCTFail("Invalid URL")
                throw URLError(.badURL)
            }
            XCTAssertTrue(url.absoluteString.contains("/\(APIEndpoint.search.rawValue)"))

            let items = comps.queryItems ?? []
            XCTAssertTrue(items.contains(.init(name: "q", value: q)))
            XCTAssertTrue(items.contains(.init(name: "lang", value: lang)))
            XCTAssertTrue(items.contains(.init(name: "max", value: String(max))))
            XCTAssertTrue(items.contains { $0.name == "token" && $0.value?.isEmpty == false })

            let body = """
            {"articles":[{"title":"S","description":"d","content":null,"url":null,"image":null,"publishedAt":null,"source":{"name":"Src","url":null}}]}
            """.data(using: .utf8)!
            return self.ok(url, body: body)
        }

        // Act
        _ = try await client.search(q, language: lang, maximumLimit: max)
    }

    // MARK: - Token handling

    func test_missingToken_throwsMissingAPIKey() async {
        // Arrange: tokenProvider returns empty
        let client = makeClient(token: "")

        // Act/Assert
        do {
            _ = try await client.topHeadlines(language: "en", maximumLimit: 5, country: nil)
            XCTFail("Expected missingAPIKey to be thrown")
        } catch let err as NewsServiceError {
            XCTAssertEqual(err, .missingAPIKey)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    // MARK: - Status mapping

    func test_status401_mapsToUserAuthenticationRequired() async {
        await assertStatusMapping(401, expectedURLError: .userAuthenticationRequired)
        await assertStatusMapping(403, expectedURLError: .userAuthenticationRequired)
    }

    func test_status429_mapsToDataNotAllowed() async {
        await assertStatusMapping(429, expectedURLError: .dataNotAllowed)
    }

    func test_status500_mapsToBadServerResponse() async {
        await assertStatusMapping(500, expectedURLError: .badServerResponse)
    }

    private func assertStatusMapping(_ status: Int, expectedURLError code: URLError.Code, file: StaticString = #filePath, line: UInt = #line) async {
        // Arrange
        let client = makeClient()

        StubURLProtocol.requestHandler = { req in
            let url = try XCTUnwrap(req.url)
            return self.response(url, status: status)
        }

        // Act/Assert
        do {
            _ = try await client.topHeadlines(language: "en", maximumLimit: 1, country: nil)
            XCTFail("Expected URLError(\(code)) for status \(status)", file: file, line: line)
        } catch let urlErr as URLError {
            XCTAssertEqual(urlErr.code, code, file: file, line: line)
        } catch {
            XCTFail("Unexpected error \(error)", file: file, line: line)
        }
    }

    // MARK: - Decoding

    func test_decoding_success_returnsArticles() async throws {
        // Arrange
        let client = makeClient()

        StubURLProtocol.requestHandler = { req in
            let url = try XCTUnwrap(req.url)
            // This JSON should match ArticlesResponse used by the client
            let body = """
            {
              "articles": [
                {
                  "title": "Apple Event",
                  "description": "Big news",
                  "content": "Long content…",
                  "url": "https://example.com/article",
                  "image": "https://example.com/img.jpg",
                  "publishedAt": "2024-01-01T12:00:00Z",
                  "source": { "name": "Apple Newsroom", "url": "https://apple.com/newsroom" }
                }
              ]
            }
            """.data(using: .utf8)!
            return self.ok(url, body: body)
        }

        // Act
        let articles = try await client.topHeadlines(language: "en", maximumLimit: 1, country: nil)

        // Assert (spot-check key fields)
        XCTAssertEqual(articles.count, 1)
        XCTAssertEqual(articles.first?.title, "Apple Event")
        XCTAssertEqual(articles.first?.source.name, "Apple Newsroom")
        XCTAssertEqual(articles.first?.url, "https://example.com/article")
    }
}
