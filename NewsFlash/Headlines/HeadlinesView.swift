//
//  HeadlinesView.swift
//  NewsFlash
//

//import SwiftUI
//
//struct HeadlinesView: View {
//    @StateObject private var viewModel = HeadlinesViewModel()
//    @State private var selectedArticle: Article?
//
//    var body: some View {
//        NavigationSplitView {
//            Group {
//                switch viewModel.state {
//                case .idle, .loading, .loaded:
//                    List(viewModel.articles, id: \._idForList) { article in
//                        NavigationLink(value: article) {
//                            ArticleRow(article: article)
//                        }
//                    }
//                    .overlay(alignment: .center) {
//                        if case .loading = viewModel.state { ProgressView("Loading…") }
//                        else if viewModel.articles.isEmpty { ContentUnavailableView("No Articles", systemImage: "newspaper", description: Text("Try searching for something else.")) }
//                    }
//                    .listStyle(.insetGrouped)
//                    .scrollIndicators(.hidden)
//                    .redacted(reason: (viewModel.state == .loading) ? .placeholder : [])
//                    .animation(.easeInOut(duration: 0.2), value: viewModel.state)
//                case let .error(message):
//                    ScrollView {
//                        VStack(spacing: 16) {
//                            ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
//                            Button {
//                                Task { await viewModel.refresh() }
//                            } label: {
//                                Label("Retry", systemImage: "arrow.clockwise")
//                            }
//                            .buttonStyle(.borderedProminent)
//                        }
//                        .padding()
//                    }
//                }
//            }
//            .searchable(text: $viewModel.query, placement: .navigationBarDrawer(displayMode: .always))
//            .searchSuggestions {
//                ForEach($viewModel.quickTopics, id: \.self) { topic in
//                    Text(topic).searchCompletion(topic)
//                }
//            }
//            .navigationTitle("NewsFlash")
//            .toolbar {
//                ToolbarItem(placement: .navigationBarTrailing) {
//                    Button { Task { await viewModel.refresh() } } label: { Image(systemName: "arrow.clockwise") }
//                }
//            }
//            .refreshable { await viewModel.refresh() }
//            .task { await viewModel.refresh() }
//            .animation(.easeInOut(duration: 0.2), value: viewModel.state)
//            .navigationDestination(for: Article.self) { article in
//                ArticleDetail(article: article)
//            }
//        } detail: {
//            if let selectedArticle {
//                ArticleDetail(article: selectedArticle)
//            } else {
//                ContentUnavailableView(
//                    "Select an article",
//                    systemImage: "newspaper",
//                    description: Text("Choose a headline to read details.")
//                )
//            }
//        }
//        .navigationSplitViewStyle(.balanced)
//    }
//}
//
//#Preview {
//    HeadlinesView()
//}

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
            .navigationTitle(NSLocalizedString("news_flash", comment: "News Flash"))
            .font(.custom("SF Pro AR Display Regular", size: 24)) // <-- Apply the custom font here
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
                    .font(.custom("SF Pro AR Display Semibold", size: 16))
                
                TextField(NSLocalizedString("search_placeholder", comment: "Search news..."), text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(.custom("SF Pro AR Display Regular", size: 16))
                
                if !viewModel.query.isEmpty {
                    Button(action: { viewModel.query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.custom("SF Pro AR Display Regular", size: 14))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding(.horizontal, 16)
            
            Divider()
        }
        .padding(.top, 8)
    }
    
    private var suggestedTopicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(NSLocalizedString("trending_topics", comment: "Trending Topics"))
                    .font(.custom("SF Pro AR Display Semibold", size: 16))
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
            ProgressView("Loading…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .loading:
            if viewModel.articles.isEmpty {
                ProgressView("Loading…")
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
            NSLocalizedString("no_articles", comment: "No Articles"),
            systemImage: "newspaper",
            description: Text(NSLocalizedString(viewModel.query.isEmpty ? "no_articles_available" : "no_articles_found", comment: "Empty state message"))
        )
    }
    
    private func errorView(message: String) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                ContentUnavailableView(
                    NSLocalizedString("unable_to_load", comment: "Unable to Load News"),
                    systemImage: "exclamationmark.triangle",
                    description: Text(NSLocalizedString(message, comment: "Error message"))
                )
                
                Button(action: refreshAction) {
                    Label(NSLocalizedString("retry", comment: "Try Again"), systemImage: "arrow.clockwise")
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
                NSLocalizedString("select_article", comment: "Select an Article"),
                systemImage: "newspaper",
                description: Text(NSLocalizedString("choose_headline", comment: "Choose a headline from the list to read the full story."))
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
                .font(.custom("SF Pro AR Display Semibold", size: 13))
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


