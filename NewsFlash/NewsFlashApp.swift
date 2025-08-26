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
    var body: some Scene {
        WindowGroup {
            HeadlinesView()
        }
    }

    init() {
        #if DEBUG
            NFX.sharedInstance().start()
        #endif
    }
}
