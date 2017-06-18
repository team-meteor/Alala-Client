//
//  WrapperViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 18..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class WrapperViewController: UIViewController {
	
	fileprivate let scrollView = UIScrollView().then {
		$0.isPagingEnabled = true
	}
	
	fileprivate let customTabBar = UIView().then {
		$0.backgroundColor = UIColor.lightGray
	}
	
	fileprivate let containerView = UIView().then {
		$0.backgroundColor = UIColor.yellow
	}
	fileprivate let cameraView = UIView().then {
		$0.backgroundColor = UIColor.blue
	}
	
	init() {
		super.init(nibName: nil, bundle: nil)
		
		//cancle 버튼 생성
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelButtonDidTap)
		)
		
		//done 버튼 생성
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .done,
			target: self,
			action: #selector(doneButtonDidTap)
		)
		
		self.automaticallyAdjustsScrollViewInsets = false
	}
	
	func cancelButtonDidTap() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func doneButtonDidTap(){
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.scrollView.addSubview(containerView)
		self.scrollView.addSubview(cameraView)
		self.view.addSubview(scrollView)
		self.view.addSubview(customTabBar)
		
		self.customTabBar.snp.makeConstraints { make in
			make.left.bottom.right.equalTo(self.view)
			make.height.equalTo(50)
		}
		
		self.scrollView.snp.makeConstraints { make in
			//make.top.equalTo((self.navigationController?.navigationBar.snp.bottom)!)
			make.left.right.equalTo(self.view)
			make.bottom.equalTo(self.customTabBar.snp.top)
		}
		
		self.containerView.snp.makeConstraints { make in
			make.edges.equalTo(self.scrollView)
			make.width.equalTo(self.scrollView.snp.width)
			make.height.equalTo(self.scrollView.snp.height)
		}
		
		self.cameraView.snp.makeConstraints { make in
			make.left.equalTo(self.containerView.snp.right)
			make.width.equalTo(self.containerView.snp.width)
			make.height.equalTo(self.containerView.snp.height)
			make.centerY.equalTo(self.containerView.snp.centerY)
		}
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.scrollView.snp.makeConstraints { make in
			make.top.equalTo(self.navigationController!.navigationBar.snp.bottom)
		}
		DispatchQueue.main.async {
			self.scrollView.contentSize = CGSize(width: self.containerView.frame.size.width * 2, height: self.containerView.frame.size.height)
		}
	}
	
}
