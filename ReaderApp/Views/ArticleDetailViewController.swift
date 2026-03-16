//
//  ArticleDetailViewController.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit
import SDWebImage

class ArticleDetailViewController: UIViewController {
    private let viewModel: ArticleDetailViewModel
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let contentLabel = UILabel()
    private let scroll = UIScrollView()
    private let stack = UIStackView()
    
    init(viewModel: ArticleDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Article"
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
        populate()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openInBrowser))
    }
    
    private func configureUI() {
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor)
        ])

        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill

        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .title2)

        authorLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        authorLabel.textColor = .secondaryLabel

        contentLabel.numberOfLines = 0
        contentLabel.font = UIFont.preferredFont(forTextStyle: .body)

        stack.addArrangedSubview(imageView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(authorLabel)
        stack.addArrangedSubview(contentLabel)
    }

    private func populate() {
        let art = viewModel.article
        titleLabel.text = art.title
        authorLabel.text = art.author
        contentLabel.text = art.content ?? art.description
        if let u = art.urlToImage, let url = URL(string: u) { imageView.setImage(url: url, placeholder: UIImage(systemName: "photo")) }
    }

    @objc private func openInBrowser() {
        guard let url = URL(string: viewModel.article.url) else { return }
        UIApplication.shared.open(url)
    }
}
