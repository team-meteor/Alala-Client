//
//  ArchiveViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 27..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class ArchiveViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Archive"
      $0.sizeToFit()
    }
  }
}
