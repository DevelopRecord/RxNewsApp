//
//  ArticleService.swift
//  RxNewsApp
//
//  Created by LeeJaeHyeok on 2022/04/13.
//

import Foundation
import Alamofire
import RxSwift

protocol ArticleServiceProtocol {
    func fetchNews() -> Observable<[Article]>
}

class ArticleService: ArticleServiceProtocol {
    func fetchNews() -> Observable<[Article]> {
        return Observable<[Article]>.create { observer in
            self.fetchNews { error, article in
                if let error = error {
                    observer.onError(error)
                }
                
                if let article = article {
                    observer.onNext(article)
                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
    
    private func fetchNews(completion: @escaping((Error?, [Article]?) -> Void)) {
        let urlString = "https://newsapi.org/v2/everything?q=tesla&from=2022-03-13&sortBy=publishedAt&apiKey=c482d4f9aefc473ba816ddda8a6c8d68"
        guard let url = URL(string: urlString) else { return completion(NSError(domain: "", code: 404, userInfo: nil), nil) }
        
        AF.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil, interceptor: nil, requestModifier: nil).responseDecodable(of: ArticleResponse.self) { response in
            if let error = response.error {
                print("URL 없음")
                return completion(error, nil)
            }
            
            if let articles = response.value?.articles {
                print("성공")
                return completion(nil, articles)
            }
        }
    }
}
