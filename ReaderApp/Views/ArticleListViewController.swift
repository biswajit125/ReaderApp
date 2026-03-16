//
//  ArticleListViewController.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit
import SDWebImage

class ArticleListViewController: UIViewController {
    let table = UITableView()
    let vm: ArticleListViewModel
    let refresh = UIRefreshControl()
    let search = UISearchController(searchResultsController: nil)

    init(viewModel: ArticleListViewModel = ArticleListViewModel()) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Top Headlines"
        tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
    }
    
    required init?(coder: NSCoder) {
        self.vm = ArticleListViewModel()
        super.init(coder: coder)
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureTable()
        configureBindings()
        vm.loadArticles()
    }

    private func configureTable() {
        table.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseId)
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        refresh.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        table.refreshControl = refresh

        // Search
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = search
        
        // Bookmark button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "bookmark"),
            style: .plain,
            target: self,
            action: #selector(openBookmarks)
        )
    }
    
    @objc private func openBookmarks() {
        let bookmarksVC = BookmarksViewController()
        navigationController?.pushViewController(bookmarksVC, animated: true)
    }


    private func configureBindings() {
        vm.onUpdate = { [weak self] in
            self?.refresh.endRefreshing()
            self?.table.reloadData()
        }
        vm.onError = { [weak self] err in
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Offline", message: "Showing cached articles. Error: \(err.localizedDescription)", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }

    @objc func handleRefresh() {
        vm.refresh()
    }
}

extension ArticleListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArticleTableViewCell.reuseId, for: indexPath) as! ArticleTableViewCell
        cell.selectionStyle = .none
        let cellVM = vm.cellViewModel(at: indexPath.row)
        cell.configure(with: cellVM)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let art = vm.article(at: indexPath.row)
        let dvm = ArticleDetailViewModel(article: art)
        let detail = ArticleDetailViewController(viewModel: dvm)
        navigationController?.pushViewController(detail, animated: true)
    }

    // Swipe to bookmark
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        print("▶ trailingSwipeActions called for row:", indexPath.row)

        let action = UIContextualAction(style: .normal, title: "Bookmark") { [weak self] _, _, completion in
            guard let self = self else { completion(false); return }

            let isBookmarked = self.vm.toggleBookmark(at: indexPath.row)
            completion(true)

            // Show a short success message depending on state
            let message = isBookmarked ? "Article bookmarked" : "Bookmark removed"
            let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            self.present(alert, animated: true)

            // auto-dismiss after 1 second
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                alert.dismiss(animated: true)
            }
        }

        // Change swipe action color dynamically based on current state
        if vm.article(at: indexPath.row).bookmarked ?? false {
            action.title = "Unbookmark"
            action.backgroundColor = .systemRed
        } else {
            action.title = "Bookmark"
            action.backgroundColor = .systemGreen
        }

        return UISwipeActionsConfiguration(actions: [action])
    }
}

extension ArticleListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        vm.search(query: searchController.searchBar.text)
    }
}
