//
//  RejectViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 17..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class RejectViewController: UIViewController {
	
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
		self.dismiss(animated: true, completion: nil)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor.yellow
		self.title = "Rejected"
	}
	
}
