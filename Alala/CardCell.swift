//
//  CardCell.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 9..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    fileprivate var post: Post?
    
    //photoView 인스턴스
    let photoView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.isUserInteractionEnabled = true
    }
    
    let messageLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //contentView에 올리기
        self.contentView.addSubview(photoView)
        self.contentView.addSubview(messageLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentView.backgroundColor = UIColor.blue
        self.photoView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.contentView)
        }
        
        self.messageLabel.snp.makeConstraints { (make) in
            make.width.equalTo(self.contentView)
            make.height.equalTo(100)
            //make.center.equalTo(self.contentView)
            make.centerX.equalTo(self.contentView)
            make.centerY.equalTo(550)
        }
    }
    
    //cell에 data 넣는 메소드
    func configure(post: Post) {
        self.post = post
        self.photoView.setImage(with: post.photoID, size: .hd)
        self.photoView.contentMode = .scaleAspectFit
        self.messageLabel.text = post.description
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


