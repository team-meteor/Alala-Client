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
	fileprivate let tableView = UITableView().then {
		$0.isScrollEnabled = false
		$0.register(PostEditorImageCell.self, forCellReuseIdentifier: "imageCell")
	}

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

		self.tableView.dataSource = self
		self.tableView.delegate = self

		self.view.addSubview(self.tableView)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.tableView.snp.makeConstraints { make in
			make.edges.equalTo(self.view)
		}

	}

}

extension PostEditorViewController: UITableViewDataSource, UITextViewDelegate {

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
		if indexPath.row == 0 { return 100 }
		return 0
	}

}
