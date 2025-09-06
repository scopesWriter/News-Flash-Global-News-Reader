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
                    .disabled(viewModel.state.isLoading)
                }
            }
            .task {
                await viewModel.loadInitialData()
            }
            .onChange(of: viewModel.query) { _, newValue in
                viewModel.queryChanged(newValue)
            }
            .navigationDestination(for: HeadlineItemViewData.self) { item in
                ArticleDetailsView(item: item) // uses convenience init to resolve DI (No Dependency Container should be called here)
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
                        TopicChip(
                            topic: String(localized: topic.localizedName),
                            isSelected: viewModel.isTopicSelected(topic),
                            action: { viewModel.toggleTopic(topic) }
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
    
    private var contentView: some View {
        List(selection: $selection) {
            switch viewModel.state {
            case .idle, .loading:
                redactedView()
            case .loaded(let items):
                loadedView(items: items)
            case .error(let err):
                errorView(error: err)
            }
        }
        .refreshable { await viewModel.refresh() }
        .listStyle(.insetGrouped)
        .scrollIndicators(.hidden)
        .listRowSpacing(8)
        .environment(\.defaultMinListRowHeight, 44)
    }
    
    private func redactedView() -> some View {
        Section {
            ForEach(0..<6, id: \.self) { _ in
                ArticleRowRedactedView()
            }
        }
        .listRowSeparator(.hidden)
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            String(localized: "no_articles"),
            systemImage: "newspaper",
            description: Text(viewModel.emptyDescriptionMessage)
        )
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }
    
    private func errorView(error: PresentationError) -> some View {
        Section {
            VStack(spacing: 20) {
                ContentUnavailableView(
                    String(localized: "unable_to_load"),
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.message)
                )
                Button(action: refreshAction) {
                    Label(String(localized: "retry"), systemImage: "arrow.clockwise")
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.state.isLoading)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .listRowSeparator(.hidden)
    }
    
    @ViewBuilder
    private func loadedView(items: [HeadlineItemViewData]) -> some View {
        if items.isEmpty {
            Section {
                emptyStateView
                    .listRowSeparator(.hidden)
            }
            .listRowSeparator(.hidden)
        } else {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    ArticleRow(item: item)
                }
            }
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
    
    // MARK: - Actions
    
    private func refreshAction() {
        Task {
            await viewModel.refresh()
        }
    }
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

// MARK: - Preview

#Preview {
    HeadlinesView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    HeadlinesView()
        .preferredColorScheme(.dark)
}
