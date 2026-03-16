//
//  NetworkService.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation
final class NetworkService {
    static let shared = NetworkService()
    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        self.session = URLSession(configuration: config)
    }

    func fetchTopHeadlines(completion: @escaping (Result<[Article], APIError>) -> Void) {
        guard let url = Endpoints.topHeadlines() else { completion(.failure(.invalidURL)); return }
        let task = session.dataTask(with: url) { data, res, err in
            if let err = err {
                completion(.failure(.serverError(err.localizedDescription)))
                return
            }
            guard let http = res as? HTTPURLResponse, 200..<300 ~= http.statusCode, let data = data else {
                completion(.failure(.invalidResponse))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(NewsAPIResponse.self, from: data)
                print("Responses: \(response.articles)")
                completion(.success(response.articles))
            } catch {
                completion(.failure(.decodingError(error)))
            }
        }
        task.resume()
    }
}
