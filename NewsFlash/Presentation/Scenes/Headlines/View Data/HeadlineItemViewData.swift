//
//  HeadlineItemViewData.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 05/09/2025.
//

import Foundation

struct HeadlineItemViewData: Identifiable, Hashable {
    let id: String
    let title: String
    let source: String
    let imageURL: URL?
    let publishedRelative: String?
    let articleURL: URL?      
    let summary: String?
    let content: String?
}
