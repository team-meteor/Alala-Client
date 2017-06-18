//
//  CameraViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 18..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
	
	private let camView = UIView().then {
		$0.backgroundColor = UIColor.black
	}
	private let scrollView = UIScrollView().then {
		$0.backgroundColor = UIColor.yellow
		$0.isPagingEnabled = true
		$0.bounces = false
	}
	
	private let bottomView = UIView().then {
		$0.backgroundColor = UIColor.green
	}
	
	private let photoButton = UIButton().then {
		$0.backgroundColor = UIColor.red
	}
	
	private let videoButton = UIButton().then {
		$0.backgroundColor = UIColor.red
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
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func cancelButtonDidTap() {
		self.dismiss(animated: true, completion: nil)
	}
	
	func doneButtonDidTap() {
		
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.bottomView.addSubview(photoButton)
		self.bottomView.addSubview(videoButton)
		self.scrollView.addSubview(bottomView)
		self.view.addSubview(camView)
		self.view.addSubview(scrollView)
		
		self.camView.snp.makeConstraints { make in
			make.left.right.equalTo(self.view)
			make.bottom.equalTo(self.scrollView.snp.top)
			make.height.equalTo(self.camView.snp.width)
		}
		
		self.scrollView.snp.makeConstraints { make in
			make.left.right.equalTo(self.view)
		}
		
		self.scrollView.snp.makeConstraints { make in
			make.height.equalTo(667 - 44 - 375 - 50)
		}
		
		self.bottomView.snp.makeConstraints { make in
			make.width.equalTo(self.view.bounds.width * 2)
			make.height.equalTo(self.scrollView.snp.height)
			make.centerY.equalTo(self.scrollView.snp.centerY)
			make.centerX.equalTo(self.view.bounds.width)
		}
		
		self.photoButton.snp.makeConstraints { make in
			make.center.equalTo(self.scrollView.snp.center)
			make.height.width.equalTo(50)
		}
		
		self.videoButton.snp.makeConstraints { make in
			make.centerX.equalTo(self.view.frame.width * 3/2)
			make.centerY.equalTo(self.scrollView.snp.centerY)
			make.width.height.equalTo(50)
		}
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		self.camView.snp.makeConstraints { make in
			make.top.equalTo((self.navigationController?.navigationBar.snp.bottom)!)
		}
		
		DispatchQueue.main.async {
			self.scrollView.contentSize = self.bottomView.bounds.size
		}
	}
}
