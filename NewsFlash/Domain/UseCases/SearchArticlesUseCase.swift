//
//  SearchArticlesUseCase.swift
//  NewsFlash
//  Created by Bishoy Badie on 04/09/2025.

// MARK: -  Refactor Note:
//  - New UseCase dedicated to article search to keep VM thin and testable.

import Foundation

// Default implementation leveraging `NewsRepositoryProtocol`.
 class SearchArticlesUseCase: SearchArticlesUseCaseProtocol {
    private let repository: NewsRepositoryProtocol

    init(repository: NewsRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        query: String,
        language: String,
        maximumLimit: Int
    ) async throws -> [Article] {
        try await repository.search(
            query,
            language: language,
            maximumLimit: maximumLimit
        )
    }
}
