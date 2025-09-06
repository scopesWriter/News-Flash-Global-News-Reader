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

extension ScreenState {
    /// True when the screen is currently performing a load of any kind.
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
}

enum LoadKind: Equatable {
    case initial
    case refresh
    case search
}
