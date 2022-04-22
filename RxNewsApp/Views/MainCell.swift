//
//  MainCell.swift
//  RxNewsApp
//
//  Created by LeeJaeHyeok on 2022/04/13.
//

import UIKit
import RxSwift
import Then
import SnapKit
import Kingfisher

class MainCell: UICollectionViewCell {
    
    public static let identifier = "MainCell"
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    var viewModel = PublishSubject<ArticleViewModel>()
    
    lazy var imageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 10
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    var titleLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 20)
    }
    
    var descriptionLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 12)
        $0.numberOfLines = 3
    }
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        setupLayout()
        subscribe()
    }
    
    func subscribe() {
        self.viewModel.subscribe(onNext: { articleViewModel in
            if let urlString = articleViewModel.imageUrl {
                self.imageView.kf.setImage(with: URL(string: urlString))
            }
            
            if let title = articleViewModel.title, let description = articleViewModel.description {
                self.titleLabel.text = title
                self.descriptionLabel.text = description
            }
        }).disposed(by: disposeBag)
    }
}

extension MainCell {
    private func setupLayout() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.top)
            make.leading.equalTo(imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().inset(40)
        }
        
        contentView.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(titleLabel.snp.leading)
            make.trailing.equalTo(titleLabel.snp.trailing)
        }
    }
}
