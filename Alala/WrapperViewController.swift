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
	
	fileprivate let containerViewController = ContainerViewController()
	fileprivate let cameraViewController = CameraViewController()
	
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
		
		self.addChildViewController(containerViewController)
		self.addChildViewController(cameraViewController)
		self.scrollView.addSubview(containerViewController.view)
		self.scrollView.addSubview(cameraViewController.view)
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
		
		self.containerViewController.view.snp.makeConstraints { make in
			make.edges.equalTo(self.scrollView)
			make.width.equalTo(self.scrollView.snp.width)
			make.height.equalTo(self.scrollView.snp.height)
		}
		
		self.cameraViewController.view.snp.makeConstraints { make in
			make.left.equalTo(self.containerViewController.view.snp.right)
			make.width.equalTo(self.containerViewController.view.snp.width)
			make.height.equalTo(self.containerViewController.view.snp.height)
			make.centerY.equalTo(self.containerViewController.view.snp.centerY)
		}
		
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.scrollView.snp.makeConstraints { make in
			make.top.equalTo(self.navigationController!.navigationBar.snp.bottom)
		}
		DispatchQueue.main.async {
			self.scrollView.contentSize = CGSize(width: self.containerViewController.view.frame.size.width * 2, height: self.containerViewController.view.frame.size.height)
		}
	}
	
}
