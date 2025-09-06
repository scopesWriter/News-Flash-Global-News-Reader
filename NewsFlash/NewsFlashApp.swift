//
//  NewsFlashApp.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import netfox
import SwiftUI

@main
struct NewsFlashApp: App {
    let container: DependencyContainer = .shared
    
    var body: some Scene {
        WindowGroup {
            HeadlinesView(viewModel: container.makeHeadlinesViewModel())
        }
    }
    
    init() {
#if DEBUG
        NFX.sharedInstance().start()
#endif
    }
}
