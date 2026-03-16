//
//  ArticleTableViewCell.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit
import SDWebImage

class ArticleTableViewCell: UITableViewCell {
    static let reuseId = "ArticleCell"
    private let thumb = UIImageView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configure()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func configure() {
        thumb.translatesAutoresizingMaskIntoConstraints = false
        thumb.contentMode = .scaleAspectFill
        thumb.clipsToBounds = true
        thumb.layer.cornerRadius = 6
        thumb.widthAnchor.constraint(equalToConstant: 90).isActive = true
        thumb.heightAnchor.constraint(equalToConstant: 60).isActive = true

        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)

        authorLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        authorLabel.textColor = .secondaryLabel

        stack.axis = .vertical
        stack.spacing = 6
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(authorLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(thumb)
        contentView.addSubview(stack)

        NSLayoutConstraint.activate([
            thumb.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
            thumb.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: thumb.trailingAnchor, constant: 12),
            stack.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor)
        ])
    }

    func configure(with vm: ArticleCellViewModel) {
        titleLabel.text = vm.title
        authorLabel.text = vm.author ?? "Unknown"
        thumb.setImage(url: vm.imageURL, placeholder: UIImage(systemName: "photo"))
    }
}
