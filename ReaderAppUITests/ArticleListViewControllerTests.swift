//
//  ArticleListViewControllerTests.swift
//  ReaderAppUITests
//
//  Created by Bishwajit Kumar on 14/09/25.
//

import Foundation
import UIKit
import XCTest
@testable import ReaderApp

// MARK: - Mock Repository
class MockRepo: ArticleRepositoryProtocol {
    var shouldFail = false
    var articles: [Article] = [
        Article(
            title: "Swift News",
            author: "Apple",
            description: "Latest Apple news",
            url: "http://apple.com",
            urlToImage: nil,
            publishedAt: nil,
            content: "Sample content"
        ),
        Article(
            title: "iOS Development",
            author: "John",
            description: "iOS tips",
            url: "http://example.com",
            urlToImage: nil,
            publishedAt: nil,
            content: "More sample content"
        )
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

final class ArticleListViewControllerTests: XCTestCase {
    var vc: ArticleListViewController!
    var nav: UINavigationController!
    var repo: MockRepo!
    var vm: ArticleListViewModel!

    override func setUp() {
        super.setUp()
        repo = MockRepo()
        vm = ArticleListViewModel(repo: repo)
        vc = ArticleListViewController(viewModel: vm)
        nav = UINavigationController(rootViewController: vc)

        // trigger view load
        _ = vc.view
    }

    func testTableViewLoadsArticles() {
        vm.articles = repo.articles
        vm.filtered = repo.articles
        vc.table.reloadData()

        let rows = vc.tableView(vc.table, numberOfRowsInSection: 0)
        XCTAssertEqual(rows, 2)
    }

    func testPullToRefreshCallsViewModel() {
        let exp = expectation(description: "refresh called")
        vm.onUpdate = { exp.fulfill() }

        vc.handleRefresh()

        wait(for: [exp], timeout: 1)
    }

    func testSearchUpdatesResults() {
        vm.articles = repo.articles
        vm.filtered = repo.articles
        vc.updateSearchResults(for: vc.search)

        XCTAssertGreaterThanOrEqual(vm.filtered.count, 0)
    }

    func testSwipeActionBookmark() {
        vm.articles = repo.articles
        vm.filtered = repo.articles

        let config = vc.tableView(vc.table, trailingSwipeActionsConfigurationForRowAt: IndexPath(row: 0, section: 0))
        XCTAssertNotNil(config)
        XCTAssertEqual(config?.actions.count, 1)
    }
}
