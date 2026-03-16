//
//  ArticleCellViewModel.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation

class ArticleCellViewModel {
    let title: String
    let author: String?
    let imageURL: URL?
    var isBookmarked: Bool = false

    init(article: Article) {
        self.title = article.title
        self.author = article.author
        if let s = article.urlToImage, let url = URL(string: s) {
            self.imageURL = url
        } else {
            self.imageURL = nil
        }
        self.isBookmarked = article.bookmarked ?? false
    }
}
