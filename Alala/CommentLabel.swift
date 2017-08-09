//
//  CommentLabel.swift
//  Alala
//
//  Created by hoemoon on 20/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import ActiveLabel

extension ActiveLabelDelegate {
  func didSelect(_ text: String, type: ActiveType) {}
}

class CommentLabel: ActiveLabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
    let creatorCustomType = ActiveType.custom(pattern: "^([\\w]+)")
    let highlightColor = UIColor(red:0.02, green:0.21, blue:0.40, alpha:1.00)
    self.enabledTypes = [.mention, .hashtag, .url, creatorCustomType]
    self.lineBreakMode = .byCharWrapping
    self.numberOfLines = 0
    self.hashtagColor = highlightColor
    self.mentionColor = highlightColor
    self.URLColor = highlightColor
    self.URLSelectedColor = highlightColor

    self.handleMentionTap { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.didSelect($0, type: .mention)
    }
    self.handleHashtagTap { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.didSelect($0, type: .hashtag)
    }
    self.handleURLTap { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.didSelect($0.absoluteString, type: .url)
    }

    // custom types
    self.customColor[creatorCustomType] = UIColor.black
    self.customSelectedColor[creatorCustomType] = UIColor.black
    self.configureLinkAttribute = { (type, attributes, isSelected) in
      var atts = attributes
      switch type {
      case creatorCustomType:
        atts[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 15)
      default:
        atts[NSFontAttributeName] = UIFont.systemFont(ofSize: 15)
      }
      return atts
    }
    self.handleCustomTap(for: creatorCustomType) { [weak self] in
      guard let strongSelf = self else { return }
      strongSelf.delegate?.didSelect($0, type: .custom(pattern: "^([\\w]+)"))
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
