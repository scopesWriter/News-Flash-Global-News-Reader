//
//  GetTopHeadlinesUseCase.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

// MARK: -  Refactor Note:
//  - New UseCase dedicated to Headlines to keep VM thin and testable.

final class TopHeadlinesUseCase: TopHeadlinesUseCaseProtocol {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        language: String,
        maximumLimit: Int,
        country: String?
    ) async throws -> [Article] {
        try await repository.topHeadlines(
            language: language,
            maximumLimit: maximumLimit,
            country: country
        )
    }
}
