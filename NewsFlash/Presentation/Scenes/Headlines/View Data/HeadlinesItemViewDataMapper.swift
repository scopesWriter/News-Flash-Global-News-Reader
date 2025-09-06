//
//  HeadlinesViewDataMapper.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 06/09/2025.
//

import Foundation

protocol HeadlinesViewDataMappingProtocol {
    func map(_ article: Article) -> HeadlineItemViewData
}

struct HeadlinesViewDataMapper: HeadlinesViewDataMappingProtocol {
    func map(_ article: Article) -> HeadlineItemViewData {
        HeadlineItemViewData(
            id: article.idForList,
            title: article.title,
            source: article.source.name ?? String(localized: "unknown_source"),
            imageURL: article.image.flatMap(URL.init(string:)),
            publishedRelative: article.publishedAt.map {
                RelativeDateTimeFormatter().localizedString(for: $0, relativeTo: Date())
            },
            articleURL: article.url.flatMap(URL.init(string:)),
            summary: article.description,
            content: article.content
        )
    }
}
