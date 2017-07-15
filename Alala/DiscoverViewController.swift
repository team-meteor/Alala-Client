//
//  DiscoverViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

  fileprivate let searchBar = UISearchBar().then {
    $0.placeholder = "검색"
    $0.barTintColor = .white
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = 1
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.tabBarItem.image = UIImage(named: "discover")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "discover-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    searchBarTextFieldColor(r: 201, g: 201, b: 206)
    configureView()

  }

  func configureView() {
    self.view.addSubview(searchBar)

    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(UIApplication.shared.statusBarFrame.maxY)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.height.equalTo(44)
    }
  }

  func searchBarTextFieldColor(r: Int, g: Int, b: Int) {
     UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = UIColor(red: r, green: g, blue: b )
  }
}
