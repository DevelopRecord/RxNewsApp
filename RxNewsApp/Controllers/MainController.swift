//
//  MainController.swift
//  RxNewsApp
//
//  Created by LeeJaeHyeok on 2022/04/13.
//

import UIKit
import RxSwift
import RxRelay
import Then
import SnapKit

class MainController: UIViewController {

    let disposeBag = DisposeBag()
    let viewModel: MainViewModel

    let articleViewModel = BehaviorRelay<[ArticleViewModel]>(value: [])
    var articleViewModelObserver: Observable<[ArticleViewModel]> {
        return articleViewModel.asObservable()
    }

    // MARK: - Properties

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .clear
        $0.delegate = self
        $0.dataSource = self
        $0.register(MainCell.self, forCellWithReuseIdentifier: MainCell.identifier)
    }

    // MARK: - Lifecycle

    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    // MARK: - Helpers

    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = viewModel.title
        setupLayout()
        fetchArticles()
        subscribe()
    }

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
}

extension MainController {
    private func setupLayout() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
}

extension MainController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return articleViewModel.value.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainCell.identifier, for: indexPath) as! MainCell
        let articleViewModel = self.articleViewModel.value[indexPath.row]
        cell.viewModel.onNext(articleViewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 120)
    }
}
