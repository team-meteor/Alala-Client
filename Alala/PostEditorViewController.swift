//
//  PostEditorViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 16..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit

class PostEditorViewController: UIViewController {
	
	fileprivate let image: UIImage
	fileprivate var message: String?
	fileprivate let tableView = UITableView()
	
	init(image: UIImage) {
		self.image = image
		super.init(nibName: nil, bundle: nil)
		self.view.backgroundColor = UIColor.yellow
		
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareButtonDidTap))
	}
	
	func shareButtonDidTap() {
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.register(PostEditorImageCell.self, forCellReuseIdentifier: "imageCell")
		self.tableView.dataSource = self
		self.tableView.delegate = self
		self.view.addSubview(self.tableView)
		
		self.tableView.snp.makeConstraints { make in
			make.edges.equalTo(self.view)
		}
	}
	
}

extension PostEditorViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! PostEditorImageCell
		cell.configure(image: self.image)
		
		return cell
	}
	
}

extension PostEditorViewController: UITableViewDelegate {
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return PostEditorImageCell.height(width: self.view.frame.width)
	}
	
}
