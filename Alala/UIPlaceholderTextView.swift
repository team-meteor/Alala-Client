//
//  UIPlaceholderTextView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 16..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

protocol UIPlaceholderTextViewDelegate :class {
  func placeholderTextViewHeightChanged(_ height: CGFloat)
}

/**
 * Placeholer를 보여줄 수 있는 커스텀 텍스트뷰
 */
class UIPlaceholderTextView: UITextView {

  public var placeholderDelgate: UIPlaceholderTextViewDelegate?

  var placeholder: String = "" {
    didSet {
      placeholderLabel.text = placeholder
    }
  }

  let placeholderLabel =  UILabel().then {
    $0.font = UIFont(name: "HelveticaNeue", size: 16)
    $0.textColor = UIColor(rgb: 0xcccccc)
    $0.sizeToFit()
  }

  // MARK: - Initialize
  override init(frame: CGRect, textContainer: NSTextContainer?) {
    super.init(frame: frame, textContainer: textContainer)
    self.setupUI()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func setupUI() {
    self.delegate = self

    self.addSubview(placeholderLabel)
    placeholderLabel.snp.makeConstraints { (make) in
      make.top.equalTo(self).offset(6)
      make.left.equalTo(self).offset(6)
      make.rightMargin.equalTo(self)
      make.bottom.equalTo(placeholderLabel.frame.height)
    }

    self.selectedTextRange = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument)
  }
}

extension UIPlaceholderTextView: UITextViewDelegate {
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

    if text.isEmpty, (textView.text.characters.count - range.length) <= 0 {
      self.placeholderLabel.isHidden = false
    } else if self.placeholderLabel.isHidden == false, !text.isEmpty {
      self.placeholderLabel.isHidden = true
    }

    return true
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    self.placeholderLabel.isHidden = textView.text.characters.count > 0 ? true : false
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    self.placeholderLabel.isHidden = !textView.text.isEmpty
  }

  func textViewDidChange(_ textView: UITextView) {
    let fixedWidth: CGFloat = textView.frame.size.width
    let newSize: CGSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    if self.placeholderDelgate != nil {
      self.placeholderDelgate?.placeholderTextViewHeightChanged(newSize.height)
    }
  }
}
