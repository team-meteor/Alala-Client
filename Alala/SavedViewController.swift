//
//  SavedViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 3..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

/**
 * # '저장됨' 화면
 *
 * **[PATH]** 내 프로필 화면 > SubMenuBar 네번째 아이콘 탭
 */
class SavedViewController: UIScrollTapMenuViewController {

  var noContentsViewForAll: NoContentsView!
  var noContentsViewForCollection: NoContentsView!

  override func viewDidLoad() {
    self.edgesForExtendedLayout = []
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = LS("saved")
      $0.sizeToFit()
    }

    // NOTE :
    // 부모VC인 UIScrollTapMenuViewController에서 NavigationItem의 유무에 따라 상단 margin을 조정하기 때문에
    // super.viewDidLoad()보다 navigationItem.titleView가 먼저 선행되어야 함
    super.viewDidLoad()

    self.firstButton.setTitle(LS("all"), for: .normal)
    self.secondButton.setTitle(LS("collection"), for: .normal)

    noContentsViewForAll = NoContentsView()
    noContentsViewForAll.guideTitleLabel.text = LS("saved")
    noContentsViewForAll.guideDescLabel.text = LS("saved_guide")
    noContentsViewForAll.addContentButton.isHidden = true
    self.firstTabView.addSubview(noContentsViewForAll)
    noContentsViewForAll.snp.makeConstraints { (make) in
      make.size.equalTo(self.firstTabView)
      make.center.equalTo(self.firstTabView)
    }

    noContentsViewForCollection = NoContentsView()
    noContentsViewForCollection.guideTitleLabel.text = LS("saved_collection")
    noContentsViewForCollection.guideDescLabel.text = LS("saved_collection_guide")
    self.secondTabView.addSubview(noContentsViewForCollection)
    noContentsViewForCollection.snp.makeConstraints { (make) in
      make.size.equalTo(self.secondTabView)
      make.center.equalTo(self.secondTabView)
    }
  }
}
