//
//  ArticleListViewModel.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import CoreData
import UIKit

class ArticleListViewModel {
    private let repo: ArticleRepositoryProtocol
    private(set) var articles: [Article] = []
    private(set) var filtered: [Article] = []
    var onUpdate: (() -> Void)?
    var onError: ((Error) -> Void)?

    init(repo: ArticleRepositoryProtocol = ArticleRepository()) {
        self.repo = repo
    }

    func loadArticles() {
        repo.fetchRemoteArticles { res in
            DispatchQueue.main.async {
                switch res {
                case .success(let arts): self.articles = arts; self.filtered = arts; self.onUpdate?()
                case .failure(let err):
                    // show cached
                    self.articles = self.repo.getCachedArticles()
                    self.filtered = self.articles
                    self.onUpdate?()
                    self.onError?(err)
                }
            }
        }
    }

    func refresh() {
        loadArticles()
    }

    func numberOfItems() -> Int { filtered.count }
    func cellViewModel(at index: Int) -> ArticleCellViewModel {
        ArticleCellViewModel(article: filtered[index])
    }

    func article(at index: Int) -> Article { filtered[index] }

    func search(query: String?) {
        guard let q = query, !q.isEmpty else { filtered = articles; onUpdate?(); return }
        filtered = articles.filter { $0.title.localizedCaseInsensitiveContains(q) }
        onUpdate?()
    }
    
    @discardableResult
       func toggleBookmark(at index: Int) -> Bool {
           let art = filtered[index]
           let newState = repo.toggleBookmark(article: art)
           self.articles = repo.getCachedArticles()
           self.filtered = self.articles

           self.onUpdate?()
           return newState
       }
}
