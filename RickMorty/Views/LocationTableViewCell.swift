//
//  LocationTableViewCell.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage

class LocationTableViewCell: UITableViewCell {
    
    // MARK: Properties
    
    static let reuseId = "locationTableViewCell"
    var favoriteAction: (() -> Void)?
    
    // MARK: SubViews
    
    private lazy var myImage = UIImageView()
    private lazy var locationLabel = UILabel()
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
        myImage.image = UIImage(systemName: "globe")
        myImage.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(50)
            $0.width.equalTo(myImage.snp.height)
        }
        
        contentView.addSubview(locationLabel)
        locationLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        locationLabel.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(10)
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
        locationText: String,
        isFavorite: Bool
    ) {
        locationLabel.text = locationText
        let favoriteImage = isFavorite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        favoriteButton.setImage(favoriteImage, for: .normal)
    }
}
