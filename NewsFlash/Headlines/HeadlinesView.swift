//
//  HeadlinesView.swift
//  NewsFlash
//

import SwiftUI

struct HeadlinesView: View {
    @StateObject private var vm = HeadlinesViewModel()
    @State private var selected: Article?

    var body: some View {
        NavigationSplitView {
            Group {
                switch vm.state {
                case .idle, .loading, .loaded:
                    List(vm.articles, id: \._idForList) { article in
                        NavigationLink(value: article) {
                            ArticleRow(article: article)
                        }
                    }
                    .overlay(alignment: .center) {
                        if case .loading = vm.state { ProgressView("Loading…") }
                        else if vm.articles.isEmpty { ContentUnavailableView("No Articles", systemImage: "newspaper", description: Text("Try searching for something else.")) }
                    }
                case let .error(message):
                    ScrollView {
                        ContentUnavailableView("Error", systemImage: "exclamationmark.triangle", description: Text(message))
                            .padding()
                    }
                }
            }
            .searchable(text: $vm.query, placement: .navigationBarDrawer(displayMode: .always))
            .navigationTitle("NewsFlash")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { Task { await vm.refresh() } } label: { Image(systemName: "arrow.clockwise") }
                }
            }
            .task { await vm.refresh() }
            .navigationDestination(for: Article.self) { art in
                ArticleDetail(article: art)
            }
        } detail: {
            if let selected {
                ArticleDetail(article: selected)
            } else {
                ContentUnavailableView("Select an article", systemImage: "newspaper", description: Text("Choose a headline to read details."))
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
}

// Convenience for List IDs when url is nil
private extension Article { var _idForList: String { url ?? id } }

#Preview { HeadlinesView() }
