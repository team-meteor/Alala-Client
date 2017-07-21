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
      $0.text = "Saved"
      $0.sizeToFit()
    }

    // NOTE :
    // 부모VC인 UIScrollTapMenuViewController에서 NavigationItem의 유무에 따라 상단 margin을 조정하기 때문에
    // super.viewDidLoad()보다 navigationItem.titleView가 먼저 선행되어야 함
    super.viewDidLoad()

    self.firstButton.setTitle("모두", for: .normal)
    self.secondButton.setTitle("컬렉션", for: .normal)

    noContentsViewForAll = NoContentsView()
    noContentsViewForAll.guideTitleLabel.text = "저장"
    noContentsViewForAll.guideDescLabel.text = "다시 보고 싶은 사진과 동영상을 저장하세요. 콘텐츠를 저장해도 다른 사람에게 알림이 전송되지 않으며, 저장된 콘텐츠는 회원님만 볼 수 있습니다."
    noContentsViewForAll.addContentButton.isHidden = true
    self.firstTabView.addSubview(noContentsViewForAll)
    noContentsViewForAll.snp.makeConstraints { (make) in
      make.size.equalTo(self.firstTabView)
      make.center.equalTo(self.firstTabView)
    }

    noContentsViewForCollection = NoContentsView()
    noContentsViewForCollection.guideTitleLabel.text = "컬렉션 저장"
    noContentsViewForCollection.guideDescLabel.text = "컬렉션을 만들어 저장하는 항목을 분류해보세요. 첫 컬렉션을 시작하려면 + 기호를 누르세요."
    self.secondTabView.addSubview(noContentsViewForCollection)
    noContentsViewForCollection.snp.makeConstraints { (make) in
      make.size.equalTo(self.secondTabView)
      make.center.equalTo(self.secondTabView)
    }
  }
}
