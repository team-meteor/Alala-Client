//
//  FeedViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//
import UIKit

class FeedViewController: UIViewController {
    
    //dummydata 불러오기
    var photoDataSource = PhotoDataSource()
    var posts = [Post]()
    
    //collectionview 인스턴스 생성
    fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
        $0.backgroundColor = .white
        $0.alwaysBounceVertical = true
        $0.register(CardCell.self, forCellWithReuseIdentifier: "cardCell")
    }
    
    fileprivate let cameraButton = UIBarButtonItem(
        image: UIImage(named: "camera")?.resizeImage(scaledTolength: 25),
        style: .plain,
        target: nil,
        action: nil
    )
    
    fileprivate let messageButton = UIBarButtonItem(
        image: UIImage(named: "message")?.resizeImage(scaledTolength: 25),
        style: .plain,
        target: nil,
        action: nil
    )
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.tabBarItem.image = UIImage(named: "feed")?.resizeImage(scaledTolength: 25)
        self.tabBarItem.selectedImage = UIImage(named: "feed-selected")?.resizeImage(scaledTolength: 25)
        self.tabBarItem.imageInsets.top = 5
        self.tabBarItem.imageInsets.bottom = -5
        self.navigationItem.leftBarButtonItem = cameraButton
        self.navigationItem.rightBarButtonItem = messageButton
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.titleView = UILabel().then {
            $0.font = UIFont(name: "IowanOldStyle-BoldItalic", size: 20)
            $0.text = "Alala"
            $0.sizeToFit()
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        //뷰에 올리고 크기설정
        self.view.addSubview(self.collectionView)
        self.collectionView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        //모델에 datasource 넣기
        posts = photoDataSource.posts
    }
}

extension FeedViewController: UICollectionViewDataSource {
    
    //cell 만들기
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! CardCell
        
        //cell 구체화
        cell.configure(post: posts[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
}

//cell 사이즈
extension FeedViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}



