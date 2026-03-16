//
//  Article.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit
import CoreData


// MARK: - Models
struct Article: Codable, Equatable {
    let title: String
    let author: String?
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: String?
    let content: String?
    var bookmarked: Bool? = false

    // Decoder keys for response
    enum CodingKeys: String, CodingKey {
        case title, author, description, url, urlToImage, publishedAt, content, bookmarked
    }
}

struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int?
    var articles: [Article]
}
