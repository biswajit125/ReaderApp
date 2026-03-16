//
//  ArticleRepository.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import CoreData
import UIKit

protocol ArticleRepositoryProtocol {
    func fetchRemoteArticles(completion: @escaping (Result<[Article], Error>) -> Void)
    func getCachedArticles() -> [Article]
    func cache(articles: [Article])
    func toggleBookmark(article: Article) -> Bool
    func getBookmarkedArticles() -> [Article]
}

class ArticleRepository: ArticleRepositoryProtocol {
    private let core = CoreDataStack.shared

    func fetchRemoteArticles(completion: @escaping (Result<[Article], Error>) -> Void) {
        NetworkService.shared.fetchTopHeadlines { res in
            switch res {
            case .success(let articles):
                // Cache in background
                DispatchQueue.global(qos: .background).async {
                    self.cache(articles: articles)
                }
                completion(.success(articles))
            case .failure(let err): completion(.failure(err))
            }
        }
    }

    func getCachedArticles() -> [Article] {
        let ctx = core.context
        let req = CachedArticle.fetchRequestForAll()
        do {
            let cached = try ctx.fetch(req)
            return cached.map { ca in
                Article(title: ca.title ?? "",
                        author: ca.author,
                        description: ca.desc,
                        url: ca.url ?? "",
                        urlToImage: ca.urlToImage,
                        publishedAt: ca.publishedAt,
                        content: ca.content)
            }
        } catch {
            print("CoreData fetch error: \(error)")
            return []
        }
    }
    
    func cache(articles: [Article]) {
        let ctx = core.context
        // Simple strategy: delete all and re-insert
        let fetchReq = NSFetchRequest<NSFetchRequestResult>(entityName: "CachedArticle")
        let deleteReq = NSBatchDeleteRequest(fetchRequest: fetchReq)
        do {
            try ctx.execute(deleteReq)
        } catch {
            print("Batch delete failed: \(error)")
        }

        for art in articles {
            let entity = NSEntityDescription.entity(forEntityName: "CachedArticle", in: ctx)!
            let ca = CachedArticle(entity: entity, insertInto: ctx)
            ca.title = art.title
            ca.author = art.author
            ca.desc = art.description
            ca.url = art.url
            ca.urlToImage = art.urlToImage
            ca.content = art.content
            ca.publishedAt = art.publishedAt
            ca.bookmarked = false
        }
        core.saveContext()
    }
    
    func toggleBookmark(article: Article) -> Bool {
        let ctx = core.context
        let req = NSFetchRequest<CachedArticle>(entityName: "CachedArticle")
        req.predicate = NSPredicate(format: "url == %@", article.url)

        var newState = false

        do {
            let results = try ctx.fetch(req)
            if let found = results.first {
                found.bookmarked.toggle()
                newState = found.bookmarked
                print("Bookmark toggled →", newState)
            } else {
                // Not in cache, add it and bookmark
                let entity = NSEntityDescription.entity(forEntityName: "CachedArticle", in: ctx)!
                let ca = CachedArticle(entity: entity, insertInto: ctx)
                ca.title = article.title
                ca.author = article.author
                ca.desc = article.description
                ca.url = article.url
                ca.urlToImage = article.urlToImage
                ca.content = article.content
                ca.publishedAt = article.publishedAt
                ca.bookmarked = true
                newState = true
            }
            core.saveContext()
        } catch {
            print("Toggle bookmark error: \(error)")
        }

        return newState
    }


    func getBookmarkedArticles() -> [Article] {
        let ctx = core.context
        let req = NSFetchRequest<CachedArticle>(entityName: "CachedArticle")
        req.predicate = NSPredicate(format: "bookmarked == YES")
        req.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        do {
            let cached = try ctx.fetch(req)
            return cached.map { ca in
                Article(title: ca.title ?? "",
                        author: ca.author,
                        description: ca.desc,
                        url: ca.url ?? "",
                        urlToImage: ca.urlToImage,
                        publishedAt: ca.publishedAt,
                        content: ca.content)
            }
        } catch {
            print("CoreData fetch bookmarks error: \(error)")
            return []
        }
    }
}

