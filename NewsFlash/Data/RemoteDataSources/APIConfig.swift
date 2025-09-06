//
//  APIConfig.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 04/09/2025.
//

import Foundation

enum GNewsAPIConfig {
    static var baseURL: URL {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: "https://\(urlString)") else {
            fatalError("Base URL not found in Info.plist or xcconfig")
        }
        return url
    }
}


