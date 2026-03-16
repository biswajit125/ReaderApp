//
//  ImageLoader.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit

class ImageLoader {
    static let shared = ImageLoader()
    private let cache = NSCache<NSString, UIImage>()

    func load(url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url.absoluteString
        if let img = cache.object(forKey: key as NSString) {
            completion(img)
            return
        }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self = self else { return }
            guard let d = data, let img = UIImage(data: d) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.cache.setObject(img, forKey: key as NSString)
            DispatchQueue.main.async { completion(img) }
        }
        task.resume()
    }
}
