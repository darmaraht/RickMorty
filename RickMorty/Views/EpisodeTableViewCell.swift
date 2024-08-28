//
//  EpisodeTableViewCell.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage

class EpisodeTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let reuseId = "epizodeTableViewCell"
    var favoriteAction: (() -> Void)?
    
    // MARK: SubViews
    
    private lazy var myImage = UIImageView()
    private lazy var episodeLabel = UILabel()
    private let favoriteButton = UIButton(type: .system)
    
    // MARK: Init
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // MARK: setup UI
    
    private func setupUI() {
        contentView.addSubview(myImage)
        myImage.image = UIImage(systemName: "film.stack")
        myImage.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(50)
            $0.width.equalTo(myImage.snp.height)
        }
        
        contentView.addSubview(episodeLabel)
        episodeLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        episodeLabel.numberOfLines = 0
        episodeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(10)
            $0.right.equalToSuperview().inset(80)
            $0.left.equalTo(myImage.snp.right).offset(20)
        }
        
        contentView.addSubview(favoriteButton)
        favoriteButton.tintColor = .red
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
        favoriteButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.right.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
        
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteAction?()
    }
    
    // MARK: setup cell subviews
    
    func setup(
        episodeText: String,
        isFavorite: Bool
    ) {
        episodeLabel.text = episodeText
        let favoriteImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton.setImage(favoriteImage, for: .normal)
    }
}
