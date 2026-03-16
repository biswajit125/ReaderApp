//
//  Endpoints.swift
//  ReaderApp
//
//  Created by Bishwajit Kumar on 13/09/25.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case invalidResponse
    case serverError(String)
    case decodingError(Error)
}

struct Endpoints {
    static var apiKey: String = "ab84dbbd1598474592c0116a710f945f"
    static var base = "https://newsapi.org/v2"

    static func topHeadlines(country: String = "us") -> URL? {
        var comps = URLComponents(string: "\(base)/top-headlines")
        comps?.queryItems = [
            URLQueryItem(name: "country", value: country),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]
        return comps?.url
    }
}
