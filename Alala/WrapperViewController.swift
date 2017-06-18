//
//  WrapperViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 18..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class WrapperViewController: UIViewController {
	
	let libraryButton = UIButton().then {
		$0.setTitle("Library", for: .normal)
		$0.addTarget(self, action: #selector(libraryButtonDidTap), for: .touchUpInside)
	}
	let photoButton = UIButton().then {
		$0.setTitle("Photo", for: .normal)
		$0.addTarget(self, action: #selector(photoButtonDidTap), for: .touchUpInside)
	}
	
	let videoButton = UIButton().then {
		$0.setTitle("Video", for: .normal)
		$0.addTarget(self, action: #selector(videoButtonDidTap), for: .touchUpInside)
	}
	
	fileprivate let scrollView = UIScrollView().then {
		$0.isPagingEnabled = true
		$0.bounces = false
	}
	
	fileprivate let customTabBar = UIView().then {
		$0.backgroundColor = UIColor.lightGray
	}
	
	fileprivate let libraryViewController = LibraryViewController()
	fileprivate let cameraViewController = UINavigationController(rootViewController: CameraViewController())
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.addChildViewController(libraryViewController)
		self.addChildViewController(cameraViewController)
		self.scrollView.addSubview(libraryViewController.view)
		self.scrollView.addSubview(cameraViewController.view)
		self.view.addSubview(scrollView)
		self.customTabBar.addSubview(libraryButton)
		self.customTabBar.addSubview(photoButton)
		self.customTabBar.addSubview(videoButton)
		self.view.addSubview(customTabBar)
		
		self.customTabBar.snp.makeConstraints { make in
			make.left.bottom.right.equalTo(self.view)
			make.height.equalTo(50)
		}
		
		self.scrollView.snp.makeConstraints { make in
			make.top.left.right.equalTo(self.view)
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
		
		self.libraryButton.snp.makeConstraints { make in
			make.width.equalTo(self.view.frame.width/3)
			make.height.equalTo(50)
			make.top.left.bottom.equalTo(self.customTabBar)
		}
		
		self.photoButton.snp.makeConstraints { make in
			make.width.equalTo(self.view.frame.width/3)
			make.height.equalTo(50)
			make.top.bottom.equalTo(self.customTabBar)
			make.left.equalTo(self.libraryButton.snp.right)
			make.right.equalTo(self.videoButton.snp.left)
		}
		self.videoButton.snp.makeConstraints { make in
			make.width.equalTo(self.view.frame.width/3)
			make.height.equalTo(50)
			make.top.right.bottom.equalTo(self.customTabBar)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		DispatchQueue.main.async {
			self.scrollView.contentSize = CGSize(width: self.libraryViewController.view.frame.size.width * 2, height: self.libraryViewController.view.frame.size.height)
		}
	}
	
	func photoButtonDidTap() {
		
	}
	
	func libraryButtonDidTap() {
		
	}
	
	func videoButtonDidTap() {
		
	}
}
