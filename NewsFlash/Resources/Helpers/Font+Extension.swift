//
//  Font+Extension.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 27/08/2025.
//


import SwiftUI

extension Font {
    static func regular(size: CGFloat) -> Font {
        return Font.custom("SF Pro AR Display Regular", size: size)
    }

    static func semibold(size: CGFloat) -> Font {
        return Font.custom("SF Pro AR Display Semibold", size: size)
    }
}
