//
//  ArticleDetailsViewModel.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 06/09/2025.
//

import Foundation

@MainActor
final class ArticleDetailsViewModel: ObservableObject {
    private let item: HeadlineItemViewData

    // Optional analytics/use-case dependency can be injected later.

    init(item: HeadlineItemViewData) {
        self.item = item
    }
    
    // MARK: - Presentation properties (computed)
    var title: String { item.title }
    var source: String { item.source }
    var imageURL: URL? { item.imageURL }
    var publishedRelative: String? { item.publishedRelative }
    var summary: String? { item.summary }
    var content: String? { item.content }
    var articleURL: URL? { item.articleURL }

    // Called when the user taps Share (for analytics/side-effects).
    // the actual share UI declarative in the View via `ShareLink`.
    func shareTapped() {
        // TODO: Inject and call a use-case here, e.g.:
    }
}
