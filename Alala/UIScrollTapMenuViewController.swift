//
//  UIScrollTapMenuViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 20..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

class UIScrollTapMenuViewController: UIViewController {

  let firstButton = UIButton().then {
    $0.setTitle("Button1", for: .normal)
    $0.setTitleColor(UIColor.black, for: .normal)
    //    $0.addTarget(self, action: #selector(allTabButtonTap(sender:)), for: .touchUpInside)
  }

  let secondButton = UIButton().then {
    $0.setTitle("Button2", for: .normal)
    $0.setTitleColor(UIColor.black, for: .normal)
    //    $0.addTarget(self, action: #selector(collectionTabButtonTap(sender:)), for: .touchUpInside)
  }

  let scrollView = UIScrollView().then {
    $0.isPagingEnabled = true
    $0.alwaysBounceHorizontal = true
    $0.showsVerticalScrollIndicator = false
    $0.showsHorizontalScrollIndicator = false
    $0.bounces = false
  }

  let menuBarView = UIBorderView()
  let menuUnderLineView = UIView().then {
    $0.backgroundColor = UIColor.black
  }
  var menuUnderLineViewLeftConstraint: Constraint?

  let firstTabView = UIView()

  let secondTabView = UIView()

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    setupUI()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func setupUI() {
    self.view.backgroundColor = UIColor.white

    self.view.addSubview(menuBarView)
    var statusBarHeight = 20
    if self.navigationItem.titleView != nil {
      statusBarHeight = 0
    }
    menuBarView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view).offset(statusBarHeight)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.height.equalTo(50)
      make.width.equalTo(self.view)
    }
    menuBarView.bottomBorderLine.isHidden = false

    menuBarView.addSubview(firstButton)
    menuBarView.addSubview(secondButton)
    firstButton.snp.makeConstraints { (make) in
      make.top.equalTo(menuBarView)
      make.left.equalTo(menuBarView)
      make.right.equalTo(secondButton.snp.left)
      make.height.equalTo(50)
      make.width.equalTo(self.view.frame.width/2)
    }
    secondButton.snp.makeConstraints { (make) in
      make.top.equalTo(menuBarView)
      make.left.equalTo(firstButton.snp.right)
      make.right.equalTo(menuBarView)
      make.width.equalTo(firstButton)
      make.height.equalTo(50)
    }

    menuBarView.addSubview(menuUnderLineView)
    menuUnderLineView.snp.makeConstraints { (make) in
      make.bottom.equalTo(menuBarView)
      make.height.equalTo(2)
      make.width.equalTo(menuBarView).dividedBy(2)
      menuUnderLineViewLeftConstraint = make.left.equalTo(0).constraint
    }

    scrollView.delegate = self
    self.view.addSubview(scrollView)
    scrollView.snp.makeConstraints { (make) in
      make.top.equalTo(menuBarView.snp.bottom)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }

    scrollView.addSubview(firstTabView)
    scrollView.addSubview(secondTabView)

    firstTabView.snp.makeConstraints { (make) in
      make.top.equalTo(scrollView)
      make.left.equalTo(scrollView)
      make.right.equalTo(secondTabView.snp.left)
      make.bottom.equalTo(scrollView)
      make.width.equalTo(scrollView)
      make.height.equalTo(scrollView)
    }
    secondTabView.snp.makeConstraints { (make) in
      make.top.equalTo(scrollView)
      make.left.equalTo(firstTabView.snp.right)
      make.right.equalTo(scrollView)
      make.bottom.equalTo(scrollView)
      make.width.equalTo(firstTabView)
      make.height.equalTo(scrollView)
    }
  }
}

extension UIScrollTapMenuViewController :UIScrollViewDelegate {
  public func scrollViewDidScroll(_ scrollView: UIScrollView) {
    print("--- \(scrollView.contentOffset.x/2)")
    self.menuUnderLineViewLeftConstraint?.update(offset: scrollView.contentOffset.x/2)
  }
}
