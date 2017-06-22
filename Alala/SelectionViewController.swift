import UIKit
import Photos

class SelectionViewController: UIViewController {
  enum Section: Int {
    case allPhotos = 0
    case smartAlbums
    case userCollections

    static let count = 3
  }
  enum CellIdentifier: String {
    case allPhotos, collection
  }
  enum SegueIdentifier: String {
    case showAllPhotos
    case showCollection
  }
  var allPhotos: PHFetchResult<PHAsset>!
  var smartAlbums: PHFetchResult<PHAssetCollection>!
  var userCollections: PHFetchResult<PHCollection>!
  var fetchResult: PHFetchResult<PHAsset>!
  var assetCollection: PHAssetCollection?
  let imageManager = PHCachingImageManager()
  let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]

  fileprivate let tableView = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.allPhotos.rawValue)
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.collection.rawValue)
  }
  fileprivate let libraryButton = UIButton().then {
    $0.backgroundColor = UIColor.red
    $0.setTitle("Library v", for: .normal)
  }

  let tileCellSpacing = CGFloat(3)

  fileprivate let baseScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.bounces = false
    $0.isPagingEnabled = true
  }
  fileprivate let scrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.maximumZoomScale = 3.0
    $0.minimumZoomScale = 0.1
    $0.zoomScale = 1.0
    $0.bounces = false
  }
  fileprivate let imageView = UIImageView()

  fileprivate let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout()).then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.backgroundColor = .white
    $0.alwaysBounceVertical = true
    $0.register(TileCell.self, forCellWithReuseIdentifier: "tileCell")
  }
  fileprivate let cropAreaView = UIView().then {
    $0.isUserInteractionEnabled = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 1 / UIScreen.main.scale
  }
  fileprivate let ButtonBarView = UIView().then {
    $0.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
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
    self.automaticallyAdjustsScrollViewInsets = false
  }
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  override func viewDidLoad() {
    super.viewDidLoad()

    self.libraryButton.addTarget(self, action: #selector(libraryButtonDidTap), for: .touchUpInside)

    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
    smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
    self.fetchResult = allPhotos

    let screenWidth = self.view.bounds.width
    let screenHeight = self.view.bounds.height
    let navigationBarHeight = self.navigationController?.navigationBar.frame.height
    let bounds = self.navigationController!.navigationBar.bounds

    self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
    self.title = "Library"
    collectionView.dataSource = self
    collectionView.delegate = self
    baseScrollView.delegate = self
    baseScrollView.contentSize = CGSize(width: screenWidth, height: screenWidth + screenHeight - screenWidth/7 - navigationBarHeight!)
    self.scrollView.addSubview(self.imageView)
    self.baseScrollView.addSubview(self.scrollView)
    self.baseScrollView.addSubview(self.cropAreaView)
    self.baseScrollView.addSubview(self.collectionView)
    self.baseScrollView.addSubview(self.ButtonBarView)
    self.view.addSubview(baseScrollView)
    self.view.addSubview(self.tableView)
    self.tableView.delegate = self
    self.tableView.dataSource = self

    self.tableView.snp.makeConstraints { make in
      make.width.equalTo(self.view)
      make.height.equalTo(self.view.frame.height - 90)
      make.centerX.equalTo(self.view)
      make.top.equalTo(self.view.snp.bottom)
    }
    self.baseScrollView.snp.makeConstraints { make in
      make.bottom.left.right.equalTo(self.view)
    }
    self.scrollView.snp.makeConstraints { make in
      make.left.right.top.equalTo(self.baseScrollView)
      make.height.equalTo(screenWidth)
      make.width.equalTo(screenWidth)
    }
    self.collectionView.snp.makeConstraints { make in
      make.left.bottom.right.equalTo(self.baseScrollView)
      make.top.equalTo(self.scrollView.snp.bottom)
      make.height.equalTo(screenHeight - screenWidth/7 - navigationBarHeight!)
      make.width.equalTo(screenWidth)
    }
    self.cropAreaView.snp.makeConstraints { make in
      make.edges.equalTo(self.scrollView)
    }
    self.ButtonBarView.snp.makeConstraints { make in
      make.left.right.equalTo(self.baseScrollView)
      make.bottom.equalTo(self.collectionView.snp.top)
      make.height.equalTo(screenWidth/7)
      make.width.equalTo(screenWidth)
    }
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    let bounds = self.navigationController!.navigationBar.bounds
    self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)

  }
  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    self.baseScrollView.snp.makeConstraints { make in
      make.top.equalTo(self.view)
    }
    self.navigationController?.navigationBar.addSubview(self.libraryButton)
    self.libraryButton.snp.makeConstraints { make in
      make.height.equalTo(40)
      make.width.equalTo(100)
      make.center.equalTo((self.navigationController?.navigationBar)!)
    }
  }

  func centerScrollView(animated: Bool) {
    let targetContentOffset = CGPoint(
      x: (self.scrollView.contentSize.width - self.scrollView.bounds.width) / 2,
      y: (self.scrollView.contentSize.height - self.scrollView.bounds.height) / 2
    )
    self.scrollView.setContentOffset(targetContentOffset, animated: animated)
  }

  func cancelButtonDidTap() {
    self.dismiss(animated: true, completion: nil)
  }
  func doneButtonDidTap() {
    guard let image = self.imageView.image else { return }
    var rect = self.scrollView.convert(self.cropAreaView.frame, from: self.cropAreaView.superview)
    rect.origin.x *= image.size.width / self.imageView.frame.width
    rect.origin.y *= image.size.height / self.imageView.frame.height
    rect.size.width *= image.size.width / self.imageView.frame.width
    rect.size.height *= image.size.height / self.imageView.frame.height
    if let croppedCGImage = image.cgImage?.cropping(to: rect) {
      let croppedImage = UIImage(cgImage: croppedCGImage)
      let postEditorViewController = PostEditorViewController(image: croppedImage)
      self.navigationController?.pushViewController(postEditorViewController, animated: true)
    }
  }

  func libraryButtonDidTap() {
    if libraryButton.currentTitle == "Library v" {
      self.libraryButton.setTitle("Library ^", for: .normal)
      UIView.animate(withDuration: 0.5, animations: {self.tableView.transform = CGAffineTransform(translationX: 0, y: -self.tableView.frame.height)})
      NotificationCenter.default.post(name: Notification.Name("hideCustomTabBar"), object: nil)
    } else if libraryButton.currentTitle == "Library ^" {
      self.libraryButton.setTitle("Library v", for: .normal)
      UIView.animate(withDuration: 0.5, animations: {self.tableView.transform = CGAffineTransform(translationX: 0, y: self.tableView.frame.height)})
      NotificationCenter.default.post(name: Notification.Name("showCustomTabBar"), object: nil)
    }
  }

}

extension SelectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! TileCell
    let asset = self.fetchResult.object(at: indexPath.item)

    cell.representedAssetIdentifier = asset.localIdentifier
    //메타데이터를 이미지로 변환
    let scale = UIScreen.main.scale
    let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
        cell.configure(photo: image!)
      }

      if asset == self.fetchResult.object(at: 0) && image != nil {
        let imageWidth = image!.size.width
        let imageHeight = image!.size.height
        if imageWidth > imageHeight {
          self.imageView.frame.size.height = self.cropAreaView.frame.height
          self.imageView.frame.size.width = self.cropAreaView.frame.height * imageWidth / imageHeight
        } else if imageWidth < imageHeight {
          self.imageView.frame.size.width = self.cropAreaView.frame.width
          self.imageView.frame.size.height = self.cropAreaView.frame.width * imageHeight / imageWidth
        } else {
          self.imageView.frame.size = self.cropAreaView.frame.size
        }
        let contentInsetTop = self.navigationController?.navigationBar.frame.height
        self.scrollView.contentInset.top = contentInsetTop!
        self.scrollView.contentSize = self.imageView.frame.size
        self.imageView.image = image
        self.centerScrollView(animated: false)
      }
    })
    return cell
  }
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return fetchResult.count
  }
}

extension SelectionViewController: UICollectionViewDelegateFlowLayout {
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let collectionViewWidth = collectionView.frame.width
    let cellWidth = round((collectionViewWidth - 2 * tileCellSpacing) / 3)
    return TileCell.size(width: cellWidth)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return tileCellSpacing
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return tileCellSpacing
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = fetchResult.object(at: indexPath.item)
    let scale = UIScreen.main.scale
    let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
      self.imageView.image = image
    })
    self.centerScrollView(animated: false)
    self.scrollView.zoomScale = 1.0
  }
}

extension SelectionViewController: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return imageView
  }
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let page = self.baseScrollView.contentOffset.y
    if page >= 44 {
      self.navigationController?.navigationBar.frame.origin.y = -44
    } else if page < 44 {
      self.navigationController?.navigationBar.frame.origin.y = -(page)
    }
  }
}

extension SelectionViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch Section(rawValue: indexPath.section)! {

    case .allPhotos:
      self.fetchResult = allPhotos

    case .smartAlbums:
      let collection: PHCollection
      collection = smartAlbums.object(at: indexPath.row)
      guard let assetCollection = collection as? PHAssetCollection
        else { fatalError("expected asset collection") }
      self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
      self.assetCollection = assetCollection

    case .userCollections:
      let collection: PHCollection
      collection = userCollections.object(at: indexPath.row)
      guard let assetCollection = collection as? PHAssetCollection
        else { fatalError("expected asset collection") }
      self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
      self.assetCollection = assetCollection

    }

    self.libraryButton.setTitle("Library v", for: .normal)
    UIView.animate(withDuration: 0.5, animations: {self.tableView.transform = CGAffineTransform(translationX: 0, y: self.tableView.frame.height)})
    NotificationCenter.default.post(name: Notification.Name("showCustomTabBar"), object: nil)
    self.collectionView.reloadData()
  }
}

extension SelectionViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return Section.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .allPhotos: return 1
    case .smartAlbums: return smartAlbums.count
    case .userCollections: return userCollections.count
    }
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    switch Section(rawValue: indexPath.section)! {
    case .allPhotos:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.allPhotos.rawValue, for: indexPath)
      cell.textLabel!.text = NSLocalizedString("All Photos", comment: "")
      return cell

    case .smartAlbums:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      let collection = smartAlbums.object(at: indexPath.row)
      cell.textLabel!.text = collection.localizedTitle
      return cell

    case .userCollections:
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      let collection = userCollections.object(at: indexPath.row)
      cell.textLabel!.text = collection.localizedTitle
      return cell
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionLocalizedTitles[section]
  }
}
