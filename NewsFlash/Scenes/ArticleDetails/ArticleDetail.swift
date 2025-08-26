//
//  ArticleDetail.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ArticleDetail: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @State private var imageHeight: CGFloat = 300
    @State private var scrollOffset: CGFloat = 0
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // Hero Image Section
                    heroImageSection(geometry: geometry)
                    
                    // Content Section
                    contentSection
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: showContent)
                }
            }
            .coordinateSpace(name: "scroll")
            .ignoresSafeArea(.container, edges: .top)
            
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: Locale.current.language.languageCode?.identifier == "ar" ? "chevron.right" : "chevron.left")
                                .font(.semibold(size: 16))
                                .foregroundColor(.primary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
    
    // MARK: - View Components
    private func heroImageSection(geometry: GeometryProxy) -> some View {
        Group {
            if let urlString = article.image, let url = URL(string: urlString) {
                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named("scroll")).minY
                    let height = max(imageHeight, imageHeight + offset)
                    
                    WebImage(url: url)
                        .onSuccess { image, data, cacheType in
                            // Handle success
                        }
                        .onFailure { error in
                            // Handle failure (e.g., show placeholder)
                        }
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: height)
                        .clipped()
                        .overlay(
                            LinearGradient(
                                colors: [Color.black.opacity(0.6), Color.clear],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .offset(y: offset > 0 ? -offset : 0)
                }
                .frame(height: imageHeight)
                .animation(.easeOut(duration: 0.6), value: showContent)
            } else {
                placeholderImage(height: imageHeight)
            }
        }
    }
    
    private func placeholderImage(height: CGFloat) -> some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Color(.systemGray5), Color(.systemGray6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(height: height)
            .overlay(
                Image(systemName: "photo")
                    .font(.regular(size: 40))
                    .foregroundColor(.secondary)
            )
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Title and Metadata
            titleAndMetadataSection
            
            // Article Content
            articleContentSection
            
            // Action Buttons
            actionButtonsSection
            
            // Bottom Spacer
            Color.clear.frame(height: 40)
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: -4)
        )
        .offset(y: -20)
    }
    
    private var titleAndMetadataSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Article Title
            Text(article.title)
                .font(.semibold(size: 24))
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
            
            // Source and Date
            HStack(spacing: 16) {
                // Source
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.accentColor.opacity(0.2))
                        .frame(width: 24, height: 24)
                        .overlay(
                            Image(systemName: "newspaper")
                                .font(.semibold(size: 12))
                                .foregroundColor(.accentColor)
                        )
                    
                    Text(article.source.name ?? Localized.unknownSource)
                        .font(.semibold(size: 15))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Published Date
                if let date = article.publishedAt {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.regular(size: 12))
                            .foregroundColor(.secondary)
                        
                        Text(timeAgoString(from: date))
                            .font(.regular(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
        }
    }
    
    private var articleContentSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let description = article.description, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Localized.summary)
                        .font(.semibold(size: 18))
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.regular(size: 16))
                        .lineSpacing(4)
                        .foregroundColor(.primary)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.accentColor.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentColor.opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            if let content = article.content, !content.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(Localized.content)
                        .font(.semibold(size: 18))
                        .foregroundColor(.primary)
                    
                    Text(content)
                        .font(.regular(size: 16))
                        .lineSpacing(6)
                        .foregroundColor(.primary)
                }
            }
        }
    }
    
    private var actionButtonsSection: some View {
        VStack(spacing: 16) {
            // Read Full Article Button
            if let link = article.url, let url = URL(string: link) {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "safari.fill")
                            .font(.semibold(size: 16))
                        
                        Text(Localized.readFullArticle)
                            .font(.semibold(size: 16))
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.semibold(size: 14))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentColor, Color.accentColor.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .shadow(color: Color.accentColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            
            // Secondary Actions
            HStack(spacing: 12) {
                // Save Button
                Button(action: {}) {
                    HStack {
                        Image(systemName: "bookmark")
                            .font(.semibold(size: 14))
                        Text(Localized.saveButton)
                            .font(.semibold(size: 14))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    )
                }
                
                Spacer()
                
                // Share Button (Alternative)
                Button(action: shareArticle) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.semibold(size: 14))
                        Text(Localized.shareButton)
                            .font(.semibold(size: 14))
                    }
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.thinMaterial)
                    )
                }
            }
        }
    }
    
    private var shareButton: some View {
        Button(action: shareArticle) {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 36, height: 36)
                .overlay(
                    Image(systemName: "square.and.arrow.up")
                        .font(.semibold(size: 16))
                        .foregroundColor(.primary)
                )
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        }
    }
    
    // MARK: - Helper Methods
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func shareArticle() {
        guard let url = article.url else { return }
        
        let activityController = UIActivityViewController(
            activityItems: [article.title, URL(string: url)!],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityController, animated: true)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ArticleDetail(article: Article(
            title: "Apple Unveils Revolutionary New Technology",
            description: "In a groundbreaking announcement, Apple has revealed its latest innovation that promises to transform the tech industry forever.",
            content: "This is the detailed content of the article that provides more information about the revolutionary technology...", url: "https://example.com",
            image: "https://via.placeholder.com/600x400",
            publishedAt: Date(),
            source: Article.Source(name: "", url: "")
        ))
    }
}
