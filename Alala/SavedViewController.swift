//
//  SavedViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 7. 3..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class SavedViewController: UIViewController {

  let allTabButton = UnderlineButton().then {
    $0.setTitle("모두", for: .normal)
    $0.setTitleColor(UIColor.black, for: .normal)
    $0.addTarget(self, action: #selector(allTabButtonTap(sender:)), for: .touchUpInside)
  }

  let collectionTabButton = UnderlineButton().then {
    $0.setTitle("컬렉션", for: .normal)
    $0.setTitleColor(UIColor.black, for: .normal)
    $0.addTarget(self, action: #selector(collectionTabButtonTap(sender:)), for: .touchUpInside)
  }

  let scrollView = UIScrollView()

  let allTabView = UIView()

  let collectionTabView = UIView()

  let noContentsGuideView = NoContentsView()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.edgesForExtendedLayout = []

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(name: "HelveticaNeue", size: 20)
      $0.text = "Saved"
      $0.sizeToFit()
    }

    setupUI()
  }

  func setupUI() {
    self.view.addSubview(allTabButton)
    self.view.addSubview(collectionTabButton)

    allTabButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(collectionTabButton.snp.left)
      make.height.equalTo(50)
    }
    collectionTabButton.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(allTabButton.snp.right)
      make.right.equalTo(self.view)
      make.width.equalTo(allTabButton)
      make.height.equalTo(50)
    }

    self.view.addSubview(allTabView)
    self.view.addSubview(collectionTabView)

    allTabView.snp.makeConstraints { (make) in
      make.top.equalTo(allTabButton.snp.bottom)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }
    collectionTabView.snp.makeConstraints { (make) in
      make.top.equalTo(allTabView)
      make.left.equalTo(allTabView.snp.right)
      make.bottom.equalTo(allTabView)
      make.width.equalTo(allTabView)
    }

//    let isNoContents = true
//
//    if(isNoContents) {
//      self.view.addSubview(noContentsGuideView)
//      noContentsGuideView.snp.makeConstraints { (make) in
//        make.top.equalTo(allTabButton.snp.bottom)
//        make.left.equalTo(self.view)
//        make.right.equalTo(self.view)
//        make.bottom.equalTo(self.view)
//      }
//    }

    /////
    allTabView.backgroundColor = UIColor.red
    collectionTabView.backgroundColor = UIColor.blue

    allTabButtonTap(sender: allTabButton)
  }

  // MARK: - User Action
  func allTabButtonTap(sender: UIButton) {
    allTabButton.isSelected = true
    collectionTabButton.isSelected = false

    UIView.animate(withDuration: 1.0, animations: {
      self.view.frame.origin.x = 0
    })
//    noContentsGuideView.guideTitleLabel.text = "저장"
//    noContentsGuideView.guideDescLabel.text = "다시 보고 싶은 사진과 동영상을 저장하세요. 콘텐츠를 저장해도 다른 사람에게 알림이 전송되지 않으며, 저장된 콘텐츠는 회원님만 볼 수 있습니다."
//    noContentsGuideView.addContentButton.isHidden = true
  }

  func collectionTabButtonTap(sender: UIButton) {
    allTabButton.isSelected = false
    collectionTabButton.isSelected = true

    UIView.animate(withDuration: 1.0, animations: {
      //self.view.frame.origin.x = -self.view.frame.size.width
    })

//    UIView.animate(withDuration: 0.5,
//                   animations: { self.view.superview?.layoutIfNeeded() }, // (2)
//      completion: { _ in
//        self.view.superview?.layoutIfNeeded() // (3)
//        self.view.isHidden = !slidingIn
//        self.button.tintColor = slidingIn ? LowerView.activeTint : LowerView.inactiveTint
//    })

//    noContentsGuideView.guideTitleLabel.text = "컬렉션 저장"
//    noContentsGuideView.guideDescLabel.text = "컬렉션을 만들어 저장하는 항목을 분류해보세요. 첫 컬렉션을 시작하려면 + 기호를 누르세요."
//    noContentsGuideView.addContentButton.isHidden = false
  }

}

class UnderlineButton: UIButton {
  var underlineView = UIView()

  let selectedColor   = UIColor(rgb: 0x111111)
  let unSelectedColor = UIColor(rgb: 0xdddddd)

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.addSubview(underlineView)
    underlineView.snp.makeConstraints { (make) in
      make.left.equalTo(self)
      make.right.equalTo(self)
      make.bottom.equalTo(self)
      make.height.equalTo(0.5)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var isSelected: Bool {
    didSet {
      switch isSelected {
      case true:
        underlineView.backgroundColor = selectedColor
        self.setTitleColor(selectedColor, for: .normal)
      case false:
        underlineView.backgroundColor = unSelectedColor
        self.setTitleColor(unSelectedColor, for: .normal)
      }
    }
  }
}
