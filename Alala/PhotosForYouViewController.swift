//
//  PhotosForYouViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 3..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * # '회원님이 나온 사진' 화면
 *
 * **[PATH]** 내 프로필 화면 > SubMenuBar 세번째 아이콘 탭
 */
class PhotosForYouViewController: UIViewController {

  let noContentsGuideView = NoContentsView()

  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = UIColor.white

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Photos for you"
      $0.sizeToFit()
    }

    // todo:
    let isNoContents = true

    if isNoContents {
      self.view.addSubview(noContentsGuideView)
      noContentsGuideView.snp.makeConstraints { (make) in
        make.top.equalTo(self.view)
        make.left.equalTo(self.view)
        make.right.equalTo(self.view)
        make.bottom.equalTo(self.view)
      }

      noContentsGuideView.guideTitleLabel.text = "회원님이 나온 사진"
      noContentsGuideView.guideDescLabel.text = "사람들이 회원님을 사진에 태그하면 태그된 사진이 여기에 표시됩니다."
      noContentsGuideView.addContentButton.isHidden = true
    }
  }
}
