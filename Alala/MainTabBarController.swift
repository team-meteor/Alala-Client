//
//  MainTabBarController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    let feedViewController = FeedViewController()
    let discoverViewController = DiscoverViewController()
    let activityViewController = ActivityViewController()
    let personalViewController = PersonalViewController()
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
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func presentCreateViewController() {
        let createViewController = CreateViewController()
        self.present(UINavigationController.init(rootViewController: createViewController), animated: true, completion: nil)
    }
}

extension MainTabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController === self.fakeViewController {
            self.presentCreateViewController()
            return false
        }
        return true
    }
}
