//
//  PresentationErrorMapper.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 06/09/2025.
//

import Foundation

protocol PresentationErrorMappingProtocol {
    func map(_ error: Error) -> PresentationError
}

struct PresentationErrorMapper: PresentationErrorMappingProtocol {
    func map(_ error: Error) -> PresentationError {
        if let domain = error as? DomainError {
            return map(domain)
        }
        if error is DecodingError {
            return .invalidResponse
        }
        return .unknown
    }

    private func map(_ error: DomainError) -> PresentationError {
        switch error {
        case .authRequired:        return .missingAuth
        case .rateLimited:         return .rateLimited
        case .networkUnavailable:  return .networkUnavailable
        case .invalidResponse,
             .decoding:            return .invalidResponse
        case .unknown:             return .unknown
        }
    }
}
