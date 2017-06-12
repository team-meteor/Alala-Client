//
//  CameraCell.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 12..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class CameraCell: UICollectionViewCell {
    
    var didTap: (() -> Void)?
    
    fileprivate let photoView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.isUserInteractionEnabled = true
    }
    
    fileprivate let photoViewTapRecognizer = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.photoView)
        
        self.photoViewTapRecognizer.addTarget(self, action: #selector(photoViewDidTap))
        self.photoView.addGestureRecognizer(self.photoViewTapRecognizer)
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
    
    
    // MARK: Actions
    
    func photoViewDidTap() {
        self.didTap?()
    }
    
}
