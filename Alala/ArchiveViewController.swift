//
//  ArchiveViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class ArchiveViewController: UIViewController {

  var noContentsView: NoContentsView!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.white

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(.navigation)
      $0.text = LS("archive")
      $0.sizeToFit()
    }

    noContentsView = NoContentsView()
    noContentsView.guideTitleLabel.text = LS("archive_no_post")
    noContentsView.guideDescLabel.text = LS("archive_no_post_guide")
    noContentsView.addContentButton.isHidden = true

    self.view.addSubview(noContentsView)
    noContentsView.snp.makeConstraints { (make) in
      make.size.equalTo(self.view)
      make.center.equalTo(self.view)
    }
  }
}
