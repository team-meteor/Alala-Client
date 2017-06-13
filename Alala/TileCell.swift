//
//  CameraCell.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 12..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class TileCell: UICollectionViewCell {
    
    var representedAssetIdentifier: String!
    
    fileprivate let photoView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.photoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Configuring
    
    func configure(photo: UIImage) {
        self.photoView.image = photo
    }
    
    
    // MARK: Size
    
    class func size(width: CGFloat) -> CGSize {
        return CGSize(width: width, height: width) // 정사각형
    }
    
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoView.frame = self.contentView.bounds
    }
    
    
}
