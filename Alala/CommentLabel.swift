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
    self.enabledTypes = [.mention, .hashtag, .url, creatorCustomType]
    self.lineBreakMode = .byCharWrapping

    self.customize { label in
      label.numberOfLines = 0
      let highlightColor = UIColor(red:0.02, green:0.21, blue:0.40, alpha:1.00)
      label.hashtagColor = highlightColor
      label.mentionColor = highlightColor
      label.URLColor = highlightColor
      label.URLSelectedColor = highlightColor

      label.handleMentionTap {
        self.delegate?.didSelect($0, type: .mention)
      }
      label.handleHashtagTap {
        self.delegate?.didSelect($0, type: .hashtag)
      }
      label.handleURLTap {
        self.delegate?.didSelect($0.absoluteString, type: .url)
      }

      // custom types
      label.customColor[creatorCustomType] = UIColor.black
      label.customSelectedColor[creatorCustomType] = UIColor.black

      label.configureLinkAttribute = { (type, attributes, isSelected) in
        var atts = attributes
        switch type {
        case creatorCustomType:
          atts[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 15)
        default:
          atts[NSFontAttributeName] = UIFont.systemFont(ofSize: 15)
        }
        return atts
      }
      label.handleCustomTap(for: creatorCustomType) {
        self.delegate?.didSelect($0, type: .custom(pattern: "^([\\w]+)"))
      }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
