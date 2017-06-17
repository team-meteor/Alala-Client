//
//  AfterRegisterViewController.swift
//  Alala
//
//  Created by hoemoon on 14/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class AfterRegisterViewController: UIViewController {
	let label = UILabel()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		label.text = "hello world"
		label.sizeToFit()
		self.view.addSubview(label)
		label.snp.makeConstraints { (make) in
			make.center.equalTo(self.view)
		}
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		self.navigationController?.isNavigationBarHidden = false
	}
	
}
