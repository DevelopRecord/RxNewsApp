//
//  MainViewModel.swift
//  RxNewsApp
//
//  Created by LeeJaeHyeok on 2022/04/13.
//

import Foundation
import RxSwift

class MainViewModel {
    let title = "News"
    
    var articleService: ArticleServiceProtocol
    
    init(articleService: ArticleServiceProtocol) {
        self.articleService = articleService
    }
    
    func fetchArticles() -> Observable<[ArticleViewModel]> {
        articleService.fetchNews().map { $0.map { ArticleViewModel(article: $0) } }
    }
}
