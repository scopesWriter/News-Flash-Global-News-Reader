//
//  DomainError.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 06/09/2025.
//

import Foundation

enum DomainError: Error, Equatable {
    case authRequired
    case rateLimited
    case networkUnavailable
    case invalidResponse
    case decoding
    case unknown
}
