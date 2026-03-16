//
//  BookmarksViewController.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit

class BookmarksViewController: UIViewController {
    
    private let table = UITableView()
    private let vm = BookmarksViewModel()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No bookmarks available"
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Bookmarks"
        tabBarItem = UITabBarItem(title: "Bookmarks", image: UIImage(systemName: "bookmark"), tag: 1)
        view.backgroundColor = .systemBackground
        
        configureTable()
        configureEmptyStateLabel()
        
        // Update UI when data is loaded
        vm.onUpdate = { [weak self] in
            guard let self = self else { return }
            self.table.reloadData()
            self.emptyStateLabel.isHidden = self.vm.numberOfItems() > 0
        }
        
        vm.loadBookmarks()
        
        // Refresh bookmarks when app comes to foreground
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(reloadBookmarks),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }

    @objc private func reloadBookmarks() {
        vm.loadBookmarks()
    }

    private func configureTable() {
        table.register(ArticleTableViewCell.self, forCellReuseIdentifier: ArticleTableViewCell.reuseId)
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(table)
        
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureEmptyStateLabel() {
        view.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension BookmarksViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.numberOfItems()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ArticleTableViewCell.reuseId,
            for: indexPath
        ) as! ArticleTableViewCell
        
        cell.selectionStyle = .none
        
        let article = vm.article(at: indexPath.row)
        cell.configure(with: ArticleCellViewModel(article: article))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let article = vm.article(at: indexPath.row)
        let detailVC = ArticleDetailViewController(viewModel: ArticleDetailViewModel(article: article))
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
