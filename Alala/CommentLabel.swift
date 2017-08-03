//
//  CommentLabel.swift
//  Alala
//
//  Created by hoemoon on 20/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import ActiveLabel

class CommentLabel: ActiveLabel {
  override init(frame: CGRect) {
    super.init(frame: frame)
    let creatorCustomType = ActiveType.custom(pattern: "^([\\w]+)")
    self.enabledTypes = [.mention, .hashtag, .url, creatorCustomType]
    self.lineBreakMode = .byCharWrapping
    self.customColor[creatorCustomType] = UIColor.black

    self.handleHashtagTap { hashtag in
      print("Success. You just tapped the \(hashtag) hashtag")
    }

    self.handleMentionTap { mention in
      print("Success. You just tapped the \(mention) mention")
    }

    self.handleURLTap { url in
      print("Success. You just tapped the \(url) url")
    }

    self.handleCustomTap(for: creatorCustomType) { creatorProfileName in
      print("Success. You just tapped the \(creatorProfileName) creatorProfileName")
    }

    self.customize { label in
      label.numberOfLines = 0
      let highlightColor = UIColor(red:0.02, green:0.21, blue:0.40, alpha:1.00)
      label.hashtagColor = highlightColor
      label.mentionColor = highlightColor
      label.URLColor = highlightColor
      label.URLSelectedColor = highlightColor

      label.handleMentionTap { print("Mention", $0) }
      label.handleHashtagTap { print("Hashtag", $0) }
      label.handleURLTap { print("URL", $0.absoluteString) }

      // custom types
      label.customColor[creatorCustomType] = UIColor.black
      label.customSelectedColor[creatorCustomType] = UIColor.black

      label.configureLinkAttribute = { (type, attributes, isSelected) in
        var atts = attributes
        switch type {
        case creatorCustomType:
          atts[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 15)
        default: ()
        }
        return atts
      }
      label.handleCustomTap(for: creatorCustomType) { print("Custom type", $0) }
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
