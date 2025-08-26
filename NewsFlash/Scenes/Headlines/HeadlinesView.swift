//
//  HeadlinesView.swift
//  NewsFlash
//

import SwiftUI

struct HeadlinesView: View {
    @StateObject private var viewModel = HeadlinesViewModel()
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                // Search Bar
                searchBarSection
                
                // Suggested Topics
                suggestedTopicsSection
                
                // Content
                contentView
            }
            .navigationTitle(Localized.newsFlash)
            .font(.regular(size: 24))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshAction) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(viewModel.state == .loading)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadInitialData()
            }
            .navigationDestination(for: Article.self) { article in
                ArticleDetail(article: article)
            }
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    // MARK: - View Components
    
    private var searchBarSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.semibold(size: 16))
                
                TextField(Localized.searchPlaceholder, text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(.regular(size: 16))
                
                if !viewModel.query.isEmpty {
                    Button(action: { viewModel.query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.regular(size: 14))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
        }
        .padding([.top, .bottom], 8)
    }
    
    private var suggestedTopicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(Localized.trendingTopics)
                    .font(.semibold(size: 16))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.quickTopics, id: \.self) { topic in
                        TopicChip(
                            topic: topic,
                            isSelected: viewModel.query.lowercased() == topic.lowercased(),
                            action: {
                                if viewModel.query.lowercased() == topic.lowercased() {
                                    viewModel.query = ""
                                } else {
                                    viewModel.query = topic
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
            }
            .frame(height: 36)
        }
        .padding(.bottom, 4)
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch viewModel.state {
        case .idle:
            ProgressView(Localized.loading)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .loading:
            if viewModel.articles.isEmpty {
                ProgressView(Localized.loading)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                articlesList
                    .redacted(reason: .placeholder)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.state)
            }
            
        case .loaded:
            if viewModel.articles.isEmpty {
                emptyStateView
            } else {
                articlesList
                    .animation(.easeInOut(duration: 0.2), value: viewModel.articles)
            }
            
        case .error(let message):
            errorView(message: message)
        }
    }
    
    private var articlesList: some View {
        List(viewModel.articles, id: \._idForList, selection: $selectedArticle) { article in
            NavigationLink(value: article) {
                ArticleRow(article: article)
            }
        }
        .listStyle(.insetGrouped)
        .scrollIndicators(.hidden)
        .listRowSpacing(8)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            Localized.noArticles,
            systemImage: "newspaper",
            description: Text(viewModel.query.isEmpty ? Localized.noArticlesAvailable : Localized.noArticlesFound)
        )
    }
    
    private func errorView(message: String) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                ContentUnavailableView(
                    Localized.unableToLoad,
                    systemImage: "exclamationmark.triangle",
                    description: Text(NSLocalizedString(message, comment: "Error message"))
                )
                
                Button(action: refreshAction) {
                    Label(Localized.retry, systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.state == .loading)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let selectedArticle {
            ArticleDetail(article: selectedArticle)
        } else {
            ContentUnavailableView(
                Localized.selectArticle,
                systemImage: "newspaper",
                description: Text(Localized.chooseHeadline)
            )
        }
    }
    
    // MARK: - Actions
    
    private func refreshAction() {
        Task {
            await viewModel.refresh()
        }
    }
}

// MARK: - TopicChip Component

struct TopicChip: View {
    let topic: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(topic)
                .font(.semibold(size: 13))
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color(.systemGray5))
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color(.systemGray4), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    HeadlinesView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HeadlinesView()
        .preferredColorScheme(.dark)
}


