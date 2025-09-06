//  ArticleDetails.swift
//  NewsFlash
//
//  Created by Bishoy Badie on 26/08/2025.
//

import SDWebImageSwiftUI
import SwiftUI

struct ArticleDetailsView: View {
    // MARK: - ViewModel

    @StateObject private var viewModel: ArticleDetailsViewModel

    // MARK: - System Private Variables

    @Environment(\.dismiss) private var dismiss
    @Environment(\.layoutDirection) private var layoutDirection
    private var imageHeight: CGFloat = 300
    @State private var isContentVisible = false

    // MARK: - Initializer

    init(viewModel: ArticleDetailsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    // Hero Image Section
                    heroImageSection(geometry: geometry)

                    // Content Section
                    contentSection
                        .opacity(isContentVisible ? 1 : 0)
                        .offset(y: isContentVisible ? 0 : 20)
                        .animation(.easeOut(duration: 0.8).delay(0.3), value: isContentVisible)
                }
            }
            .coordinateSpace(name: "scroll")
            .ignoresSafeArea(.container, edges: .top)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }
                ) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: layoutDirection == .rightToLeft ? "chevron.right" : "chevron.left")
                                .font(.semibold(size: 16))
                                .foregroundColor(.primary)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .accessibilityLabel(String(localized: "back"))
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                shareButton
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                isContentVisible = true
            }
        }
    }

    // MARK: - View Components

    private func heroImageSection(geometry: GeometryProxy) -> some View {
        Group {
            if let url = viewModel.imageURL {
                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named("scroll")).minY
                    let height = max(imageHeight, imageHeight + offset)

                    WebImage(url: url)
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
                .animation(.easeOut(duration: 0.6), value: isContentVisible)
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
            Text(viewModel.title)
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

                    Text(viewModel.source.isEmpty ? String(localized: "unknown_source") : viewModel.source)
                        .font(.semibold(size: 15))
                        .foregroundColor(.primary)
                }

                Spacer()

                // Published Date
                if let rel = viewModel.publishedRelative, !rel.isEmpty {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.regular(size: 12))
                            .foregroundColor(.secondary)

                        Text(rel)
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
            if let description = viewModel.summary, !description.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "summary"))
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

            if let content = viewModel.content, !content.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "content"))
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
            if let url = viewModel.articleURL {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "safari.fill")
                            .font(.semibold(size: 16))

                        Text(String(localized: "read_full_article"))
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
                Button(action: {
                    // TODO: ToggleBookmark UseCase
                }) {
                    HStack {
                        Image(systemName: "bookmark")
                            .font(.semibold(size: 14))
                        Text(String(localized: "save_button"))
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
                .accessibilityLabel(String(localized: "save_button"))

                Spacer()

                // Share Button (Alternative)
                if let url = viewModel.articleURL {
                    ShareLink(item: url) {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .font(.semibold(size: 14))
                            Text(String(localized: "share_button"))
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
                    .simultaneousGesture(TapGesture().onEnded { viewModel.shareTapped() })
                }
            }
        }
    }

    @ViewBuilder
    private var shareButton: some View {
        if let url = viewModel.articleURL {
            ShareLink(item: url) {
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
            .simultaneousGesture(
                TapGesture()
                    .onEnded {
                        viewModel.shareTapped()
                    }
            )
        }
    }
}

// A convenience init that accepts item: HeadlineItemViewData and calls your DI factory:
// Note: - This init added to avoid calling DependencyContainer in Views in order to avoid coupling
extension ArticleDetailsView {
    @MainActor
    init(item: HeadlineItemViewData, container: DependencyContainer = .shared) {
        self.init(viewModel: container.makeArticleDetailsViewModel(item: item))
    }
}

// MARK: - Preview

#Preview("ArticleDetails", traits: .portrait) {
    NavigationStack {
        ArticleDetailsView(
                item: HeadlineItemViewData(
                    id: "1",
                    title: "Apple Unveils Revolutionary New Technology",
                    source: "Apple Newsroom",
                    imageURL: URL(string: "https://via.placeholder.com/600x400"),
                    publishedRelative: "2h",
                    articleURL: URL(string: "https://example.com"),
                    summary: "In a groundbreaking announcement...",
                    content: "This is the detailed content..."
                )
        )
    }
}
