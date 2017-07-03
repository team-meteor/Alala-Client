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
  var videoData: Data?
  var urlAsset: AVURLAsset?

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

  func shareButtonDidTap() {
    if urlAsset != nil {
      let videoUrl = urlAsset?.url
      var movieData: Data?
      do {
        movieData = try Data(contentsOf: videoUrl!)
      } catch _ {
        movieData = nil
        return
      }

      MultipartService.uploadMultipart(image: self.image, videoData: movieData!, progress: nil) { multipartId in
        print("ida = \(multipartId)")
        PostService.postWithSingleMultipart(multipartId: multipartId, message: self.message, progress: nil) { [weak self] response in
          guard let `self` = self else { return }
          switch response.result {
          case .success(let post):
            print("업로드 성공 = \(post)")
            self.dismiss(animated: true, completion: nil)
          case .failure(let error):

            print(error)
          }
        }
      }
    } else {

      MultipartService.uploadMultipart(image: self.image, videoData: self.videoData, progress: nil) { multipartId in
        print("idb = \(multipartId)")
        PostService.postWithSingleMultipart(multipartId: multipartId, message: self.message, progress: nil) { [weak self] response in
          guard let `self` = self else { return }
          switch response.result {
          case .success(let post):
            print("업로드 성공 = \(post)")
            self.dismiss(animated: true, completion: nil)
          case .failure(let error):

            print(error)
          }
        }

      }

    }
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

  override func didMove(toParentViewController parent: UIViewController?) {
    if parent == nil {
      NotificationCenter.default.post(name: Notification.Name("cameraStart"), object: nil)
    }
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
