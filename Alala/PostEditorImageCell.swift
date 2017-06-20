//
//  PostEditorImageCell.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 16..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class PostEditorImageCell: UITableViewCell {

	let photoView = UIImageView()
	let textView = UITextView().then {
		$0.text = "내용 입력..."
		$0.textColor = UIColor.lightGray
	}

	override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		self.selectionStyle = .none
		self.contentView.addSubview(self.photoView)
		self.contentView.addSubview(self.textView)
		self.textView.delegate = self
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Configuring

	func configure(image: UIImage) {
		self.photoView.image = image
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.photoView.snp.makeConstraints { make in
			make.left.top.bottom.equalTo(self.contentView)
			make.width.equalTo(self.contentView.snp.height)
			make.height.equalTo(self.photoView.snp.width)
		}
		self.textView.snp.makeConstraints { make in
			make.top.right.bottom.equalTo(self.contentView)
			make.left.equalTo(self.photoView.snp.right)
		}
	}
}

extension PostEditorImageCell: UITextViewDelegate {
	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.textColor == UIColor.lightGray {
			textView.text = nil
			textView.textColor = UIColor.black
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		if textView.text.isEmpty {
			textView.text = "내용 입력..."
			textView.textColor = UIColor.lightGray
		}
	}
}
