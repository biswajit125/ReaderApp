//
//  ArticleListViewModelTests.swift.swift
//  ReaderAppTests
//
//  Created by Bishwajit Kumar on 14/09/25.
//


import Foundation
import UIKit
import XCTest
@testable import ReaderApp

@testable import ReaderApp

extension Article {
    init(
        id: Int = 0,
        title: String,
        author: String? = nil,
        description: String? = nil,
        url: String,
        urlToImage: String? = nil,
        publishedAt: Date? = nil,
        content: String? = nil,
        isBookmarked: Bool = false
    ) {
        self.init(
            title: title,
            author: author,
            description: description,
            url: url,
            urlToImage: urlToImage,
            publishedAt: publishedAt,
            content: content
        )
        //self.isBookmarked = isBookmarked
    }
}


class MockRepo: ArticleRepositoryProtocol {
    var shouldFail = false
    var articles: [Article] = [
        Article(id: 1, title: "Swift News", author: "Apple", url: "http://apple.com", urlToImage: nil, isBookmarked: false),
        Article(id: 2, title: "iOS Development", author: "John", url: "http://example.com", urlToImage: nil, isBookmarked: false)
    ]

    func fetchRemoteArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        if shouldFail {
            completion(.failure(NSError(domain: "Test", code: -1, userInfo: nil)))
        } else {
            completion(.success(articles))
        }
    }

    func getCachedArticles() -> [Article] {
        return articles
    }

    func toggleBookmark(article: Article) {
        if let idx = articles.firstIndex(where: { $0.title == article.title }) {
            articles[idx].bookmarked?.toggle()
        }
    }
}

final class ArticleListViewModelTests: XCTestCase {
    var vm: ArticleListViewModel!
    var repo: MockRepo!

    override func setUp() {
        super.setUp()
        repo = MockRepo()
        vm = ArticleListViewModel(repo: repo)
    }

    func testLoadArticlesSuccess() {
        let exp = expectation(description: "onUpdate called")
        vm.onUpdate = { exp.fulfill() }

        vm.loadArticles()

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(vm.numberOfItems(), 2)
        XCTAssertEqual(vm.articles.first?.title, "Swift News")
    }

    func testLoadArticlesFailureUsesCache() {
        repo.shouldFail = true
        let exp = expectation(description: "onUpdate called")

        vm.onUpdate = { exp.fulfill() }
        vm.onError = { error in
            XCTAssertNotNil(error)
        }

        vm.loadArticles()
        wait(for: [exp], timeout: 1)

        XCTAssertEqual(vm.numberOfItems(), 2) // fallback cache
    }

    func testSearchFiltersArticles() {
        vm.articles = repo.articles
        vm.filtered = repo.articles

        let exp = expectation(description: "onUpdate called")
        vm.onUpdate = { exp.fulfill() }

        vm.search(query: "swift")

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(vm.numberOfItems(), 1)
        XCTAssertEqual(vm.article(at: 0).title, "Swift News")
    }

    func testSearchWithEmptyQueryResetsFilter() {
        vm.articles = repo.articles
        vm.filtered = []

        let exp = expectation(description: "onUpdate called")
        vm.onUpdate = { exp.fulfill() }

        vm.search(query: nil)

        wait(for: [exp], timeout: 1)
        XCTAssertEqual(vm.numberOfItems(), 2)
    }

    func testToggleBookmarkUpdatesRepo() {
        vm.articles = repo.articles
        vm.filtered = repo.articles

        vm.toggleBookmark(at: 0)
        XCTAssertTrue((repo.articles[0].bookmarked != nil))

        vm.toggleBookmark(at: 0)
        XCTAssertFalse((repo.articles[0].bookmarked != nil))
    }
}
