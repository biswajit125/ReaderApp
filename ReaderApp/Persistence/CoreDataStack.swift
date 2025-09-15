//
//  CoreDataStack.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import CoreData
import UIKit

class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ReaderApp")
        container.loadPersistentStores { storeDesc, error in
            if let err = error {
                fatalError("Unresolved Core Data error: \(err)")
            }
        }
        return container
    }()

    var context: NSManagedObjectContext { persistentContainer.viewContext }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do { try context.save() }
            catch { print("CoreData save error: \(error)") }
        }
    }
}

extension CachedArticle {
    static func fetchRequestForAll() -> NSFetchRequest<CachedArticle> {
        let req = NSFetchRequest<CachedArticle>(entityName: "CachedArticle")
        req.sortDescriptors = [NSSortDescriptor(key: "publishedAt", ascending: false)]
        return req
    }
}

