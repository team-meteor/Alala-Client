//
//  CommentCell.swift
//  Alala
//
//  Created by hoemoon on 01/07/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class CommentContainerCell: UICollectionViewCell {
  static var inset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
  var comments = [Comment]()
  fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .white
    $0.alwaysBounceVertical = true
    $0.register(CommentCell.self, forCellWithReuseIdentifier: "commentCell")
  }
  override func layoutSubviews() {
    super.layoutSubviews()
    self.collectionView.dataSource = self
//    self.collectionView.delegate = self
  }
}

extension CommentContainerCell: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    // 동적으로 바꿔야 함
    // 작성자가 단 댓글만 보여줘야 함
    return comments.count
  }
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    return UICollectionViewCell()
  }
}
