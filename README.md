# ReaderApp

1.SDWebImage
Used to load and cache images asynchronously from remote URLs in UIImageView.

Example usage:
imageView.sd_setImage(with: URL(string: "https://example.com/image.png"), placeholderImage: UIImage(named: "placeholder"))

This helps improve performance by handling image caching automatically.

2.Kingfisher
An alternative to SDWebImage, used to download and cache images efficiently.

Example usage:
imageView.kf.setImage(with: URL(string: "https://example.com/image.png"))

It also provides advanced features like image processors and cache management.

3.Alamofire
Used to simplify network requests instead of using URLSession directly.

Example usage:
AF.request("https://api.example.com/data").responseJSON { response in
    switch response.result {
    case .success(let data):
        print("Success: \(data)")
    case .failure(let error):
        print("Error: \(error.localizedDescription)")
    }
}

Alamofire handles HTTP methods, parameter encoding, and response serialization, making network code cleaner and easier to maintain
