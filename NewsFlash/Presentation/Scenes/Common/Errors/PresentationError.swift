//
//  PresentationError.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 05/09/2025.
//

import Foundation

enum PresentationError: Equatable {
    case missingAuth
    case rateLimited
    case networkUnavailable
    case invalidResponse
    case unknown
}

extension PresentationError {
    var message: String {
        switch self {
        case .networkUnavailable: return String(localized: "network_unavailable")
        case .missingAuth: return String(localized: "missing_api_key")
        case .rateLimited: return String(localized: "rate_limited")
        case .invalidResponse: return String(localized: "invalid_response")
        case .unknown: return String(localized: "unable_to_load")
        }
    }
}
