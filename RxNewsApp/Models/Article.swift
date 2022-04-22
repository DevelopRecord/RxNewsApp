//
//  Article.swift
//  RxNewsApp
//
//  Created by LeeJaeHyeok on 2022/04/13.
//

import Foundation

struct ArticleResponse: Codable {
    var status: String?
    var totalResults: Int
    var articles: [Article]
}

struct Article: Codable {
//    var source: Source
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
}

struct Source: Codable {
    var id: String
    var name: String
}
