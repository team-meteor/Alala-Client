//
//  PostEditorImageCell.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 16..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class PostEditorImageCell: UITableViewCell {
	
	fileprivate let photoView = UIImageView()

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		self.contentView.addSubview(self.photoView)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Configuring
	
	func configure(image: UIImage) {
		self.photoView.image = image
	}
	
	// MARK: Size
	
	class func height(width: CGFloat) -> CGFloat {
		return width // 정사각형
	}
	
	// MARK: Layout
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.photoView.frame = self.contentView.bounds
	}

}
