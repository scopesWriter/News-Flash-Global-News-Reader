//
//  Topic.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 06/09/2025.
//

import Foundation

enum Topic: String, CaseIterable, Hashable {
    case technology
    case apple
    case ai
    case ios
    case swift
    case business
    case science
    case health
    case sports
    case entertainment
    case politics
    case climate
    
    var queryValue: String { rawValue }

    /// Localized display name for the topic using String Catalog
    var localizedName: LocalizedStringResource {
        switch self {
        case .technology: return "technology"
        case .apple: return "apple"
        case .ai: return "ai"
        case .ios: return "ios"
        case .swift: return "swift"
        case .business: return "business"
        case .science: return "science"
        case .health: return "health"
        case .sports: return "sports"
        case .entertainment: return "entertainment"
        case .politics: return "politics"
        case .climate: return "climate"
        }
    }
}
