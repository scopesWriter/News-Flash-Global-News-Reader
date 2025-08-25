//
//  NewsServiceURLTests.swift
//  NewsFlashTests
//
//  Created by Bishoy Badie on 26/08/2025.
//

@testable import NewsFlash
import XCTest

final class NewsServiceURLTests: XCTestCase {
    private struct TestTokenProvider: TokenProvider { let token: String }
    
    private var session: URLSession!
    private var service: NewsService!
    
    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolMock.self]
        session = URLSession(configuration: config)
        service = NewsService(
            session: session,
            baseURL: GNewsAPI.base,
            tokenProvider: TestTokenProvider(token: "TEST_TOKEN")
        )
    }
    
    override func tearDown() {
        service = nil
        session = nil
        URLProtocolMock.requestHandler = nil
        super.tearDown()
    }
    
    func testTopHeadlines_buildsExpectedQueryItems() async throws {
        // Arrange
        let expectedJSON = """
        {"totalArticles":1,"articles":[{"title":"Hello","description":null,"content":null,"url":"https://e.com","image":null,"publishedAt":"2024-01-01T12:00:00Z","source":{"name":"Src","url":"https://s.com"}}]}
        """.data(using: .utf8)!
        URLProtocolMock.requestHandler = { request in
            // Assert path
            XCTAssertTrue(request.url?.path.contains("top-headlines") == true)
            
            // Assert query params
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let query = Dictionary(uniqueKeysWithValues: components.queryItems!.map { ($0.name, $0.value ?? "") })
            XCTAssertEqual(query["lang"], "en")
            XCTAssertEqual(query["max"], "5")
            XCTAssertNotNil(query["token"]) // key is required (value may be blank locally)
            return (HTTPURLResponse.ok(for: request.url!), expectedJSON)
        }
        
        // Act
        _ = try await service.topHeadlines(language: "en", maximumLimit: 5, country: nil)
    }
    
    func testSearch_buildsExpectedQueryItems() async throws {
        let expectedJSON = """
        {"totalArticles":0,"articles":[]}
        """.data(using: .utf8)!
        URLProtocolMock.requestHandler = { request in
            XCTAssertTrue(request.url?.path.contains("search") == true)
            let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            let query = Dictionary(uniqueKeysWithValues: components.queryItems!.map { ($0.name, $0.value ?? "") })
            XCTAssertEqual(query["q"], "apple")
            XCTAssertEqual(query["lang"], "en")
            XCTAssertEqual(query["max"], "30")
            return (HTTPURLResponse.ok(for: request.url!), expectedJSON)
        }
        
        _ = try await service.search("apple", language: "en", maximumLimit: 30)
    }
    
    func testRateLimitMapsToURLErrorDataNotAllowed() async {
        URLProtocolMock.requestHandler = { request in
            (HTTPURLResponse(statusCode: 429, url: request.url!), Data())
        }
        
        do {
            _ = try await service.topHeadlines(language: "en", maximumLimit: 1, country: nil)
            XCTFail("Expected error")
        } catch let error as URLError {
            XCTAssertEqual(error.code, .dataNotAllowed)
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
}

// MARK: - URLProtocolMock

final class URLProtocolMock: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    
    override func startLoading() {
        guard let handler = URLProtocolMock.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() { }
}

// MARK: - Helpers

private extension HTTPURLResponse {
    static func ok(for url: URL?) -> HTTPURLResponse {
        HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    convenience init(statusCode: Int, url: URL?) {
        self.init(url: url!, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
