//
//  UIPlaceholderTextView.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 16..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class UIPlaceholderTextView: UITextView, UITextViewDelegate {
  var placeholder: String = ""

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

    self.text = placeholder

    self.selectedTextRange = self.textRange(from: self.beginningOfDocument, to: self.beginningOfDocument)
  }

  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

    // Combine the textView text and the replacement text to
    // create the updated text string
    //let currentText = textView.text
    let updatedText = text

    // If updated text view will be empty, add the placeholder
    // and set the cursor to the beginning of the text view
    if updatedText.isEmpty {

      textView.text = placeholder
      textView.textColor = UIColor.lightGray

      textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

      return false
    }

      // Else if the text view's placeholder is showing and the
      // length of the replacement string is greater than 0, clear
      // the text view and set its color to black to prepare for
      // the user's entry
    else if textView.textColor == UIColor.lightGray && !text.isEmpty {
      textView.text = nil
      textView.textColor = UIColor.black
    }

    return true
  }

  func textViewDidBeginEditing(_ textView: UITextView) {
    textView.textColor = textView.text.characters.count > 0 ? UIColor.black : UIColor.lightGray
  }

  func textViewDidEndEditing(_ textView: UITextView) {
    if textView.text.isEmpty {
      textView.text = placeholder
      textView.textColor = UIColor.lightGray
    }
  }
}
