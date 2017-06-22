//
//  MainTabBarController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import Photos

class MainTabBarController: UITabBarController {

  let feedViewController = FeedViewController()
  let discoverViewController = DiscoverViewController()
  let activityViewController = ActivityViewController()
  let personalViewController = PersonalViewController()
  var statusBarShouldBeHidden = false
  let fakeViewController = UIViewController().then {
    $0.tabBarItem.image = UIImage(named: "plus")?.resizeImage(scaledTolength: 25)
    $0.tabBarItem.imageInsets.top = 5
    $0.tabBarItem.imageInsets.bottom = -5
  }
  init() {
    super.init(nibName: nil, bundle: nil)
    self.delegate = self
    self.viewControllers = [
      UINavigationController(rootViewController: self.feedViewController),
      self.discoverViewController,
      fakeViewController,
      activityViewController,
      personalViewController
    ]
  }
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Show the status bar
    statusBarShouldBeHidden = false
    self.setNeedsStatusBarAppearanceUpdate()
  }
  override var prefersStatusBarHidden: Bool {
    return statusBarShouldBeHidden
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  fileprivate func presentWrapperViewController() {
    let wrapperViewController = WrapperViewController()
    self.present(wrapperViewController, animated: true, completion: nil)
  }
}

extension MainTabBarController: UITabBarControllerDelegate {

  func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
    if viewController === self.fakeViewController {
      self.presentWrapperViewController()
      return false
    }
    return true
  }

}
