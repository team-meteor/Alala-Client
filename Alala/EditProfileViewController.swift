//
//  EditProfileViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 28..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "EditProfile"
      $0.sizeToFit()
    }
  }
}
