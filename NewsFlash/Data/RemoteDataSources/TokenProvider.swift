//
//  TokenProvider.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

/// Abstraction to supply the API token (so we can swap sources for tests/CI)
protocol TokenProvider {
    var token: String { get }
}

/// Default token provider that reads from Info.plist (key: `GNEWS_API_KEY`)
struct InfoPlistTokenProvider: TokenProvider {
    var token: String {
        (Bundle.main.object(forInfoDictionaryKey: "GNEWS_API_KEY") as? String) ?? ""
    }
}


