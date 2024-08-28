//
//  CharacterCollectionListCellView.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage

class CharacterCollectionListCellView: UICollectionViewCell {
    
    // MARK: SubViews
    
    private lazy var view = UIView()
    
    private lazy var nameLabel = UILabel()
    
    private lazy var myImage = UIImageView()
    
    private lazy var speciesLabel = UILabel()
    
    // MARK: Properties
    
    static let reuseId = "characterListCell"
    
    // MARK: Init
       
       override init(frame: CGRect) {
           super.init(frame: frame)
           setupUI()
       }
       
       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
    
    // MARK: setup UI
    
    private func setupUI() {
        contentView.addSubview(view)
        view.layer.cornerRadius = 20
        view.backgroundColor = .secondarySystemGroupedBackground
        view.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(contentView)
        }
        
        view.addSubview(myImage)
        myImage.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(50)
            $0.width.equalTo(myImage.snp.height)
        }
        myImage.layer.cornerRadius = 15
        myImage.clipsToBounds = true
        
        view.addSubview(nameLabel)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        nameLabel.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(10)
            $0.left.equalTo(myImage.snp.right).offset(20)
        }
        
        view.addSubview(speciesLabel)
        speciesLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(7)
            $0.left.equalTo(myImage.snp.right).offset(20)
        }
    }
    
    // MARK: setup cell subviews
    
    func setup(
        text: String,
        imageURLString: String,
        speciesText: String
    ) {
        nameLabel.text = text
        speciesLabel.text = speciesText
        myImage.sd_setImage(with: URL(string: imageURLString))
    }
}
