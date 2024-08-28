//
//  EpisodeDetailInfoCell.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage

class EpisodeDetailInfoCell: UITableViewCell {
    
    // MARK: SubViews
    
    private lazy var episodeNameLabel = UILabel()
    private lazy var episodeDateLabel = UILabel()
    
    // MARK: Properties
    
    static let reuseId = "episodeDetailInfoCell"
    
    // MARK: Init
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: Setup UI
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemGray6
        
        contentView.addSubview(episodeNameLabel)
        episodeNameLabel.font = UIFont.boldSystemFont(ofSize: 20)
        episodeNameLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview().inset(10)
        }
        
        contentView.addSubview(episodeDateLabel)
        episodeDateLabel.font = UIFont.boldSystemFont(ofSize: 15)
        episodeDateLabel.snp.makeConstraints {
            $0.bottom.left.right.equalToSuperview().inset(10)
            $0.top.equalTo(episodeNameLabel.snp.bottom).offset(10)
        }
    }
    
    // MARK: setup cell subviews
    
    func setup(
        episodeName: String,
        episodeDate: String
    ) {
        episodeNameLabel.text = String(localized: "movieTitle") + episodeName
        episodeDateLabel.text = String(localized: "showDate") + episodeDate
    }
}
