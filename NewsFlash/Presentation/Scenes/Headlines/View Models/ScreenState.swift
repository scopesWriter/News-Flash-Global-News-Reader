//
//  ScreenState.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 05/09/2025.
//

import Foundation

enum ScreenState: Equatable {
    case idle
    case loading(LoadKind)
    case loaded([HeadlineItemViewData])
    case error(PresentationError)
}

enum LoadKind: Equatable {
    case initial
    case refresh
    case search
}
