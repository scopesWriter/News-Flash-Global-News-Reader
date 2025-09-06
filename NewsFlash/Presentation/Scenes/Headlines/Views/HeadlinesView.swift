//
//  HeadlinesView.swift
//  NewsFlash
//  Created by Bishoy Badie on 26/08/2025.
//

import SwiftUI

struct HeadlinesView: View {
    // MARK: - State Managment Variables
    @StateObject private var viewModel: HeadlinesViewModel
    @State private var selection: HeadlineItemViewData?
    
    // MARK: - Initializer
    init(viewModel: HeadlinesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
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
            .navigationTitle(String(localized: "news_flash"))
            .font(.regular(size: 24))
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: refreshAction) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                await viewModel.loadInitialData()
            }
            .onChange(of: viewModel.query) {
                viewModel.queryChanged(viewModel.query)
            }
            .navigationDestination(for: HeadlineItemViewData.self) { item in
                ArticleDetailsView(item: item) // uses convenience init to resolve DI
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
                
                TextField(String(localized: "search_placeholder"), text: $viewModel.query)
                    .textFieldStyle(.plain)
                    .font(.regular(size: 16))
                
                if !viewModel.query.isEmpty {
                    Button(action: { viewModel.query = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.regular(size: 14))
                    }
                    .accessibilityLabel(String(localized: "clear_search"))
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
                Text(String(localized: "trending_topics"))
                    .font(.semibold(size: 16))
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(viewModel.topics, id: \.self) { topic in
                        let id = topic.rawValue
                        TopicChip(
                            topic: String(localized: "topic_\(id)"),
                            isSelected: viewModel.query.caseInsensitiveCompare(id) == .orderedSame,
                            action: {
                                if viewModel.query.caseInsensitiveCompare(id) == .orderedSame {
                                    viewModel.query = ""
                                } else {
                                    viewModel.query = id
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
            ProgressView(String(localized: "loading"))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        case .loading(let kind):
            // Show full-screen spinner for initial load; skeleton for others
            if case .initial = kind {
                ProgressView(String(localized: "loading"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // We don't have items here, so show a lightweight placeholder
                articlesList([])
                    .redacted(reason: .placeholder)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.state)
            }
            
        case .loaded(let items):
            if items.isEmpty {
                emptyStateView
            } else {
                articlesList(items)
                    .animation(.easeInOut(duration: 0.2), value: items)
            }
            
        case .error(let err):
            errorView(error: err)
        }
    }
    
    private func articlesList(_ items: [HeadlineItemViewData]) -> some View {
        List(items, selection: $selection) { item in
            NavigationLink(value: item) {
                ArticleRow(item: item)
            }
        }
        .listStyle(.insetGrouped)
        .scrollIndicators(.hidden)
        .listRowSpacing(8)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            String(localized: "no_articles"),
            systemImage: "newspaper",
            description: Text(emptyDescriptionMessage)
        )
    }

    
    private func errorView(error: PresentationError) -> some View {
        return ScrollView {
            VStack(spacing: 20) {
                ContentUnavailableView(
                    String(localized: "unable_to_load"),
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.title)
                )
                Button(action: refreshAction) {
                    Label(String(localized: "retry"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isLoading)
            }
            .padding()
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let item = selection {
            ArticleDetailsView(item: item)
        } else {
            ContentUnavailableView(
                String(localized: "select_article"),
                systemImage: "newspaper",
                description: Text(String(localized: "choose_headline"))
            )
        }
    }
    
    // MARK: - Derived State
    private var isLoading: Bool {
        if case .loading = viewModel.state { return true }
        return false
    }
    
    private var emptyDescriptionMessage: String {
        viewModel.query.isEmpty
                          ? String(localized: "no_articles_available")
                          : String(localized: "no_articles_found \(viewModel.query)")
    }
    
    // MARK: - Actions
    
    private func refreshAction() {
        Task {
            await viewModel.refresh()
        }
    }
}

// MARK: - Preview

#Preview {
    HeadlinesView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HeadlinesView()
        .preferredColorScheme(.dark)
}

// MARK: - Refactor Note:

// Keep the first as the designated init, and optionally add a this init that resolves from the container, you don't have to add @MainActor in DependencyContainer.
// Usage example:
// HeadlinesView() // uses .shared under the hood, just a way to instantiate the VM with @mainActor addition

// MARK: - Convenience Init

extension HeadlinesView {
    @MainActor
    init(container: DependencyContainer = .shared) {
        self.init(viewModel: container.makeHeadlinesViewModel())
    }
}
