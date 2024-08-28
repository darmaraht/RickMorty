//
//  CharacterTableViewCell.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import Foundation
import SnapKit
import SDWebImage

final class CharacterTableViewCell: UITableViewCell {
    
    // MARK: Subviews
    
    private lazy var view = UIView()
    private lazy var myImage = UIImageView()
    private lazy var nameLabel = UILabel()
    private lazy var speciesLabel = UILabel()
    
    // MARK: Properties
    
    static let reuseId = "characterTableViewCell"
    
    // MARK: Init
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    // MARK: Setup UI
    
    private func setupUI() {
        contentView.addSubview(view)
        view.layer.cornerRadius = 15
        view.backgroundColor = .secondarySystemGroupedBackground
        view.snp.makeConstraints {
            $0.top.bottom.equalTo(contentView).inset(3)
            $0.left.right.equalTo(contentView).inset(15)
        }
        
        view.addSubview(myImage)
        myImage.layer.cornerRadius = 15
        myImage.clipsToBounds = true
        myImage.snp.makeConstraints {
            $0.top.left.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(100)
            $0.width.equalTo(myImage.snp.height)
        }
        
        view.addSubview(nameLabel)
        nameLabel.font = UIFont.boldSystemFont(ofSize: 20.0)
        nameLabel.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(10)
            $0.left.equalTo(myImage.snp.right).offset(20)
        }
        
        view.addSubview(speciesLabel)
        speciesLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(10)
            $0.left.equalTo(myImage.snp.right).offset(20)
        }
    }
    
    func setup(
        imageURL: String,
        nameText: String,
        speciesText: String
    ) {
        myImage.sd_setImage(with: URL(string: imageURL))
        nameLabel.text = nameText
        speciesLabel.text = speciesText
    }
}
