//
//  NewsFlashApp.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import SwiftData
import SwiftUI
//import netfox

@main
struct NewsFlashApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // for the sake of API debugging
        //#if DEBUG
          //  NFX.sharedInstance().start()
        //#endif
    }

    var body: some Scene {
        WindowGroup {
            HeadlinesView()
        }
        .modelContainer(sharedModelContainer)
    }
}
