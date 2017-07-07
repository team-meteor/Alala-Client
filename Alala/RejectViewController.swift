//
//  RejectViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 17..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class RejectViewController: UIViewController {
  fileprivate let goToSettingButton = UIButton().then {
    $0.setTitle("Go To Setting Apps", for: .normal)
    $0.addTarget(self, action: #selector(goToSetting), for: .touchUpInside)
    $0.setTitleColor(UIColor.black, for: .normal)
  }

	init() {
		super.init(nibName: nil, bundle: nil)

		//cancle 버튼 생성
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelButtonDidTap)
		)

		self.automaticallyAdjustsScrollViewInsets = false
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func cancelButtonDidTap() {
		//self.dismiss(animated: true, completion: nil)
    NotificationCenter.default.post(name: Notification.Name("dismissWrapperVC"), object: nil)
	}

  deinit {
    NotificationCenter.default.removeObserver(self)
    print("reject deinit")
  }

	override func viewDidLoad() {
		super.viewDidLoad()
    self.view.addSubview(goToSettingButton)
		self.view.backgroundColor = UIColor.yellow
		self.title = "Rejected"

    self.goToSettingButton.snp.makeConstraints { make in
      make.height.equalTo(100)
      make.width.equalTo(300)
      make.center.equalTo(self.view)
    }
	}

  func goToSetting() {
    UIApplication.shared.open(URL(string:UIApplicationOpenSettingsURLString)!)
  }

}
