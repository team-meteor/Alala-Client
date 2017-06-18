//
//  WrapperViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 18..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class WrapperViewController: UIViewController {
	
	let libraryLabel = UILabel().then {
		$0.text = "Library"
		$0.textAlignment = .center
	}
	let photoLabel = UILabel().then {
		$0.text = "Photo"
		$0.textAlignment = .center
	}
	let videoLabel = UILabel().then {
		$0.text = "Video"
		$0.textAlignment = .center
	}
	
	fileprivate let scrollView = UIScrollView().then {
		$0.isPagingEnabled = true
	}
	
	fileprivate let customTabBar = UIView().then {
		$0.backgroundColor = UIColor.lightGray
	}
	
	fileprivate let libraryViewController = LibraryViewController()
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
		
		self.addChildViewController(libraryViewController)
		self.addChildViewController(cameraViewController)
		self.scrollView.addSubview(libraryViewController.view)
		self.scrollView.addSubview(cameraViewController.view)
		self.view.addSubview(scrollView)
		self.customTabBar.addSubview(libraryLabel)
		self.customTabBar.addSubview(photoLabel)
		self.customTabBar.addSubview(videoLabel)
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
		
		self.libraryViewController.view.snp.makeConstraints { make in
			make.edges.equalTo(self.scrollView)
			make.width.equalTo(self.scrollView.snp.width)
			make.height.equalTo(self.scrollView.snp.height)
		}
		
		self.cameraViewController.view.snp.makeConstraints { make in
			make.left.equalTo(self.libraryViewController.view.snp.right)
			make.width.equalTo(self.libraryViewController.view.snp.width)
			make.height.equalTo(self.libraryViewController.view.snp.height)
			make.centerY.equalTo(self.libraryViewController.view.snp.centerY)
		}
		
		self.libraryLabel.snp.makeConstraints { make in
			make.width.equalTo(self.view.frame.width/3)
			make.height.equalTo(50)
			make.top.left.bottom.equalTo(self.customTabBar)
		}
		
		self.photoLabel.snp.makeConstraints { make in
			make.width.equalTo(self.view.frame.width/3)
			make.height.equalTo(50)
			make.top.bottom.equalTo(self.customTabBar)
			make.left.equalTo(self.libraryLabel.snp.right)
			make.right.equalTo(self.videoLabel.snp.left)
		}
		self.videoLabel.snp.makeConstraints { make in
			make.width.equalTo(self.view.frame.width/3)
			make.height.equalTo(50)
			make.top.right.bottom.equalTo(self.customTabBar)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.scrollView.snp.makeConstraints { make in
			make.top.equalTo(self.navigationController!.navigationBar.snp.bottom)
		}
		DispatchQueue.main.async {
			self.scrollView.contentSize = CGSize(width: self.libraryViewController.view.frame.size.width * 2, height: self.libraryViewController.view.frame.size.height)
		}
	}
	
}
