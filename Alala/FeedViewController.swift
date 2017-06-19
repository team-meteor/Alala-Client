import UIKit
import Alamofire

class FeedViewController: UIViewController {
  
  let dummyDataSource = DummyDataSource()
  
  fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.backgroundColor = .clear
    $0.alwaysBounceVertical = true
    $0.register(PostCardCell.self, forCellWithReuseIdentifier: "cardCell")
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
    
    self.view.addSubview(self.collectionView)
    
    self.collectionView.snp.makeConstraints { make in
      make.size.equalToSuperview()
    }
  }
  
}

extension FeedViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 5
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! PostCardCell
    let dummyData = dummyDataSource.dummyData
    
    cell.configure(dummyData[indexPath.item])
    
    return cell
  }
}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let dummyData = dummyDataSource.dummyData
    let image = UIImage(named: dummyData[indexPath.item])
    let layout = collectionViewLayout as! UICollectionViewFlowLayout
    
//    layout.itemSize = (image?.setImage())!
    return layout.itemSize
  }
  
}
