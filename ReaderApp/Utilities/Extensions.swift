//
//  Extensions.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func setImage(url: URL?, placeholder: UIImage? = nil) {
        self.image = placeholder
        guard let url = url else { return }
        ImageLoader.shared.load(url: url) { [weak self] img in
            if let img = img { self?.image = img }
        }
    }
}
