//
//  BookmarksViewModel.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation

class BookmarksViewModel {
    private let repo: ArticleRepositoryProtocol
    private(set) var bookmarks: [Article] = []
    var onUpdate: (() -> Void)?

    init(repo: ArticleRepositoryProtocol = ArticleRepository()) {
        self.repo = repo
    }

    func loadBookmarks() {
        bookmarks = repo.getBookmarkedArticles()
        onUpdate?()
    }

    func numberOfItems() -> Int { bookmarks.count }
    func article(at index: Int) -> Article { bookmarks[index] }
}
