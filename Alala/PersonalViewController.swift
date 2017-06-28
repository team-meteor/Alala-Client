//
//  PersonalViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class PersonalViewController: UIViewController, PersonalInfoViewDelegate, NoContentsViewDelegate {

  // MARK:- UI Objects
  let discoverPeopleButton = UIBarButtonItem(
    image: UIImage(named: "plus")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: self,
    action: #selector(PersonalViewController.discoverPeopleButtonTap)
  )

  let archiveButton = UIBarButtonItem(
    image: UIImage(named: "personal")?.resizeImage(scaledTolength: 25),
    style: .plain,
    target: nil,
    action: nil
  )
    
  let scrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = true
    $0.bounces = true
  }
  
  let personalInfoView = PersonalInfoView()
  
  let noContentsGuideView = NoContentsView()
  
  // MARK:- Initialize
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.tabBarItem.image = UIImage(named: "personal")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "personal-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5
    
    self.navigationItem.leftBarButtonItem = discoverPeopleButton
    self.navigationItem.rightBarButtonItem = archiveButton
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.titleView = UILabel().then {
        $0.font = UIFont(name: "HelveticaNeue", size: 20)
        $0.text = "User ID"
        $0.sizeToFit()
    }
    
    self.view.addSubview(scrollView)
    scrollView.snp.makeConstraints { (make) in
        make.top.equalTo(self.view)
        make.left.equalTo(self.view)
        make.right.equalTo(self.view)
        make.bottom.equalTo(self.view)
    }
    
    //-- Section 1 : closable notice view (Optional)
    // TODO
    
    //-- Section 2 : personal infomation view (Required)
    scrollView.addSubview(personalInfoView)
    personalInfoView.snp.makeConstraints { (make) in
        make.top.equalTo(scrollView)
        make.left.equalTo(scrollView)
        make.right.equalTo(scrollView)
        make.bottom.equalTo(personalInfoView.profileNameLabel.snp.bottom).offset(10)
        make.width.equalTo(scrollView)
    }
    personalInfoView.delegate = self
    
    //-- Section 3 : personal post list or no contents view (one of both)
    scrollView.addSubview(noContentsGuideView)
    noContentsGuideView.snp.makeConstraints { (make) in
      make.top.equalTo(personalInfoView.snp.bottom)
      make.left.equalTo(scrollView)
      make.right.equalTo(scrollView)
      //make.bottom.equalTo(scrollView)
      make.bottom.equalTo(self.view.snp.bottom)
    }
    noContentsGuideView.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  // MARK:- PersonalInfoViewDelegate
  func discoverPeopleButtonTap() {
    let sampleVC = DiscoverPeopleViewController()
    self.navigationController?.pushViewController(sampleVC, animated: true)
  }
  
  func postsAreaTap() {
    print("----- postsAreaTap")
  }
  
  func followersAreaTap() {
    let followerVC = FollowViewController(type:.follower)
    self.navigationController?.pushViewController(followerVC, animated: true)
  }
  
  func followingAreaTap() {
    let followingVC = FollowViewController(type:.following)
    self.navigationController?.pushViewController(followingVC, animated: true)
  }
  
  func editProfileButtonTap(sender: UIButton) {
    print("----- editProfileButtonTap")
//    let sampleVC = DiscoverPeopleViewController()
//    self.navigationController?.
  }

  func optionsButtonTap(sender: UIButton) {
    print("----- optionsButtonTap")
  }

  // MARK:- NoContentsViewDelegate
  func addContentButtonTap(sender: UIButton) {
    print("'Share your first photo or video' button pressed.")
  }
  
  /*
  func logoutButtonDidTap() {
    AuthService.instance.logout { (success) in
      if success {
        NotificationCenter.default.post(name: .presentLogin, object: nil, userInfo: nil)
      } else {

      }
    }
  }
 */
}
