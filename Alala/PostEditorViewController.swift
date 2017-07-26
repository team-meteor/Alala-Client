//
//  PostEditorViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 16..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Photos

class PostEditorViewController: UIViewController {

  fileprivate let image: UIImage
  fileprivate var message: String?
  var multipartArr = [Any]()

  fileprivate let tableView = UITableView().then {
    $0.isScrollEnabled = false
    $0.register(PostEditingCell.self, forCellReuseIdentifier: "postEditingCell")
  }

  init(image: UIImage) {
    self.image = image
    super.init(nibName: nil, bundle: nil)
    self.view.backgroundColor = UIColor.yellow
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(shareButtonDidTap))
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
      make.left.top.right.equalTo(self.view)
      make.width.equalTo(self.view)
      make.height.equalTo(300)
    }
  }

  override func didMove(toParentViewController parent: UIViewController?) {
    if parent == nil {
      NotificationCenter.default.post(name: Notification.Name("cameraStart"), object: nil)
    }
  }

  func shareButtonDidTap() {
    self.navigationItem.rightBarButtonItem?.isEnabled = false
    var postDic = [String: Any]()
    postDic["multipartArr"] = self.multipartArr
    postDic["message"] = self.message
    NotificationCenter.default.post(
      name: NSNotification.Name(rawValue: "preparePosting"),
      object: self,
      userInfo: ["postDic": postDic]
    )
    self.dismiss(animated: true, completion: nil)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

extension PostEditorViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "postEditingCell", for: indexPath) as! PostEditingCell
    cell.imageConfigure(image: self.image)
    cell.textDidChange = { [weak self] message in
      guard let `self` = self else { return }
      self.message = message
      self.tableView.beginUpdates()
      self.tableView.endUpdates()
      self.tableView.scrollToRow(at: indexPath, at: .none, animated: false)
    }
    return cell
  }
}

extension PostEditorViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 0 { return 100 }
    return 0
  }

}
