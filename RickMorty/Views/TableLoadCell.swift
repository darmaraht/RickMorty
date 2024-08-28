//
//  TableLoadCell.swift
//  RickMorty
//
//  Created by Денис Королевский on 9/8/24.
//

import UIKit
import SnapKit
import SDWebImage

class TableLoadCell: UITableViewCell {
    
    // MARK: SubViews
        
    private lazy var activitiIndicator = UIActivityIndicatorView(style: .large )
    
    // MARK: Properties
    
    static let reuseId = "loadCell"
    
    // MARK: Init
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(activitiIndicator)
        activitiIndicator.snp.makeConstraints {
            $0.centerX.equalTo(contentView)
            $0.centerY.equalTo(contentView)
            
        }
    }
    
    func animate() {
        activitiIndicator.startAnimating()
    }
}
