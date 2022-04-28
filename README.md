# RxNewsApp
newsapi.org의 JSON 정보를 가져와서 뉴스 앱을 만듭니다.

## 목차

[1. 라이브러리](#라이브러리)   
[2. 프레임워크](#프레임워크)   
[3. 미리보기](#미리보기)   
[4. 설명](#설명)   

#### 라이브러리   
|이름|목적|버전|
|:------:|:---:|:---:|
|Then|클로저를 통한 인스턴스 생성 시 깔끔한 코드 작성|2.7.0|
|SnapKit|Auto layout|5.6.0|
|Alamofire|HTTP 통신|5.5.0|
|Kingfisher|URL 이미지 주소를 가진 이미지 불러오기|7.2.1|
|RxSwift|비동기 & 이벤트 처리|6.5.0|
   
#### 프레임워크
- UIKit
   
#### 미리보기
메인화면에서 기사의 이미지, 제목, 본문 설명을 볼 수 있습니다.
![RxNewsApp-preview](https://user-images.githubusercontent.com/76255765/165709850-2b9d1702-2235-4625-ab92-4c8d0c0cbee0.gif)

   
#### 코드 간단 설명
   
* JSON 형식에 맞는 Model 생성
<pre><code>
struct ArticleResponse: Codable {
    var status: String?
    var totalResults: Int
    var articles: [Article]
}

struct Article: Codable {
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
    var content: String?
}
</code></pre>

* 데이터 통신할 서비스 함수 생성
  * Alamofire의 GET 통신
<pre><code>
private func fetchNews(completion: @escaping((Error?, [Article]?) -> Void)) {
    let urlString = "https://newsapi.org/v2/everything?q=tesla&from=2022-03-28&sortBy=publishedAt&apiKey=c482d4f9aefc473ba816ddda8a6c8d68"
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
</code></pre>

* ViewModel 생성
   * ArticleViewModel
<pre><code>
struct ArticleViewModel {
    private let article: Article
    
    var imageUrl: String? {
        return article.urlToImage
    }
    
    var title: String? {
        return article.title
    }
    
    var description: String? {
        return article.description
    }
    
    init(article: Article) {
        self.article = article
    }
}
</code></pre>
   * MainViewModel 
<pre><code>
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
</code></pre>

* MainController 데이터 뿌려주기
   * MainViewModel 프로퍼티 생성 및 초기화
<pre><code>
let viewModel: MainViewModel

init(viewModel: MainViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
}

required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
}
</code></pre>

   * ArticleViewModel 프로퍼티 및 옵저버 생성
<pre><code>
let articleViewModel = BehaviorRelay<[ArticleViewModel]>(value: []) // 초기값 지정
var articleViewModelObserver: Observable<[ArticleViewModel]> {
    return articleViewModel.asObservable() // 값이 바뀔 때 마다 반영
}
</code></pre>

   * Article 정보 가져오기
<pre><code>
func fetchArticles() {
    viewModel.fetchArticles().subscribe(onNext: { articleViewModel in
        self.articleViewModel.accept(articleViewModel)
    }).disposed(by: disposeBag)
}

func subscribe() {
    self.articleViewModelObserver.observe(on: MainScheduler.instance).subscribe(onNext: { articles in
        self.collectionView.reloadData()
    }).disposed(by: disposeBag)
}
</code></pre>

   * CollectionView에 데이터 뿌려주기
<pre><code>
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return articleViewModel.value.count
}

func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.identifier, for: indexPath) as! MainCell
    let articleViewModel = self.articleViewModel.value[indexPath.row]
    cell.viewModel.onNext(articleViewModel)
    return cell
}
