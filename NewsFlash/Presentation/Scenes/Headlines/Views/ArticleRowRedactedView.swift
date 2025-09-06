//
//  ArticleRowRedactedView.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 07/09/2025.
//

import SwiftUI

struct ArticleRowRedactedView: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .frame(width: 88, height: 88)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 18)
                RoundedRectangle(cornerRadius: 4)
                    .frame(height: 14)
                    .opacity(0.8)
                HStack(spacing: 8) {
                    Circle()
                        .frame(width: 10, height: 10)
                    RoundedRectangle(cornerRadius: 3)
                        .frame(width: 80, height: 10)
                }
            }
        }
        .foregroundStyle(.placeholder)
        .redacted(reason: .placeholder)
    }
}
