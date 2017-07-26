//
//  ActivityViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class ActivityViewController: UIScrollTapMenuViewController {

  var noContentsViewForFollowing: NoContentsView!
  var noContentsViewForMe: NoContentsView!

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.tabBarItem.image = UIImage(named: "heart")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "heart-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    self.firstButton.setTitle(LS("activity_from_follow_menu"), for: .normal)
    self.secondButton.setTitle(LS("activity_you_menu"), for: .normal)

    noContentsViewForFollowing = NoContentsView()
    noContentsViewForFollowing.guideTitleLabel.text = LS("activity_from_follow_title")
    noContentsViewForFollowing.guideDescLabel.text = LS("activity_from_follow_guide")
    noContentsViewForFollowing.addContentButton.setTitle(LS("activity_from_follow_button"), for: .normal)
    self.firstTabView.addSubview(noContentsViewForFollowing)
    noContentsViewForFollowing.snp.makeConstraints { (make) in
      make.size.equalTo(self.firstTabView)
      make.center.equalTo(self.firstTabView)
    }

    noContentsViewForMe = NoContentsView()
    noContentsViewForMe.guideTitleLabel.text = LS("activity_you_title")
    noContentsViewForMe.guideDescLabel.text = LS("activity_you_guide")
    noContentsViewForMe.addContentButton.setTitle(LS("share_photos_and_videos_button"), for: .normal)
    self.secondTabView.addSubview(noContentsViewForMe)
    noContentsViewForMe.snp.makeConstraints { (make) in
      make.size.equalTo(self.secondTabView)
      make.center.equalTo(self.secondTabView)
    }
  }
}
