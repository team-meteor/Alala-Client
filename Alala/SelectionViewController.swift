import UIKit
import Photos
import AVKit

class SelectionViewController: UIViewController {
  var playerLayer: AVPlayerLayer?
  var urlAsset: AVURLAsset?
  let photosLimit: Int = 500
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
  var smartAlbumsFetchResult: PHFetchResult<PHAsset>!
  var userCollectionsFetchResult: PHFetchResult<PHAsset>!
  var assetCollection: PHAssetCollection?
  let imageManager = PHCachingImageManager()
  let tileCellSpacing = CGFloat(1)
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

  fileprivate let baseScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.bounces = false
    $0.isPagingEnabled = true
  }
  fileprivate let scrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.maximumZoomScale = 3
    $0.alwaysBounceVertical = true
    $0.alwaysBounceHorizontal = true
    $0.isUserInteractionEnabled = true
    $0.clipsToBounds = true
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
    getLimitedAlbumFromLibrary()

    self.libraryButton.addTarget(self, action: #selector(libraryButtonDidTap), for: .touchUpInside)
    let screenWidth = self.view.bounds.width
    let screenHeight = self.view.bounds.height
    let navigationBarHeight = self.navigationController?.navigationBar.frame.height
    let bounds = self.navigationController!.navigationBar.bounds
    self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
    self.title = "Library"

    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.baseScrollView.delegate = self
    self.scrollView.delegate = self
    self.tableView.delegate = self
    self.tableView.dataSource = self
    self.baseScrollView.contentSize = CGSize(width: screenWidth, height: screenHeight * 2 / 3 + screenHeight - screenWidth/7 - navigationBarHeight!)

    self.baseScrollView.addSubview(self.scrollView)
    self.baseScrollView.addSubview(self.cropAreaView)
    self.baseScrollView.addSubview(self.collectionView)
    self.baseScrollView.addSubview(self.ButtonBarView)
    self.scrollView.addSubview(self.imageView)
    self.view.addSubview(baseScrollView)
    self.view.addSubview(self.tableView)

    //constraints
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
      make.height.equalTo(screenHeight * 2 / 3)
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
      make.top.equalTo((self.navigationController?.navigationBar.snp.bottom)!)
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

  func getLimitedAlbumFromLibrary() {
    let limitedOptions = PHFetchOptions()
    let sortOptions = PHFetchOptions()
    limitedOptions.fetchLimit = photosLimit
    sortOptions.fetchLimit = photosLimit
    sortOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

    allPhotos = PHAsset.fetchAssets(with: sortOptions)
    smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: limitedOptions)
    userCollections = PHCollectionList.fetchTopLevelUserCollections(with: limitedOptions)
    self.fetchResult = allPhotos
  }

  func getAllAlbums() {
    let AllOptions = PHFetchOptions()
    AllOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    allPhotos = PHAsset.fetchAssets(with: AllOptions)
    smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: nil)
    userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
  }

  func getCropImage() -> UIImage {
    let image = self.imageView.image!
    var rect = self.scrollView.convert(self.cropAreaView.frame, from: self.cropAreaView.superview)
    rect.origin.x *= image.size.width / self.imageView.frame.width
    rect.origin.y *= image.size.height / self.imageView.frame.height
    rect.size.width *= image.size.width / self.imageView.frame.width
    rect.size.height *= image.size.height / self.imageView.frame.height
    let croppedCGImage = image.cgImage?.cropping(to: rect)
    return UIImage(cgImage: croppedCGImage!)
  }

  func doneButtonDidTap() {
    let croppedImage = getCropImage()
    let postEditorViewController = PostEditorViewController(image: croppedImage)
    postEditorViewController.urlAsset = self.urlAsset
    self.navigationController?.pushViewController(postEditorViewController, animated: true)
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

  func scaleAspectFillSize(image: UIImage, imageView: UIImageView) {
    var imageWidth = image.size.width
    var imageHeight = image.size.height

    imageView.frame.size = scrollView.frame.size

    let imageViewWidth = imageView.frame.size.width
    let imageViewHeight = imageView.frame.size.height

    if imageWidth >= imageHeight {
      imageWidth = imageWidth * imageViewHeight / imageHeight
      imageHeight = imageViewHeight
    } else if imageWidth < imageHeight {
      imageHeight = imageHeight * imageViewWidth / imageWidth
      imageWidth = imageViewWidth
    }
    imageView.frame.size = CGSize(width: imageWidth, height: imageHeight)

  }

}

extension SelectionViewController: UICollectionViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    if self.allPhotos.count == photosLimit && self.fetchResult == self.allPhotos {
      getAllAlbums()
      self.fetchResult = self.allPhotos
      self.collectionView.reloadData()
    }
  }
}

extension SelectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! TileCell
    let asset = self.fetchResult.object(at: indexPath.item)
    cell.representedAssetIdentifier = asset.localIdentifier
    let scale = UIScreen.main.scale
    let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
        cell.configure(photo: image!)
      }
      if asset == self.fetchResult.object(at: 0) && image != nil {
        self.scaleAspectFillSize(image: image!, imageView: self.imageView)
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
    let cellWidth = round((collectionViewWidth - 2 * tileCellSpacing) / 4)
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

    if asset.mediaType == .video {
      imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: {(asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable : Any]?) -> Void in
        if let urlAsset = asset as? AVURLAsset {
          self.urlAsset = urlAsset
          let localVideoUrl: URL = urlAsset.url as URL
          self.imageView.image = self.previewImageFromVideo(videoUrl: localVideoUrl)
          self.centerScrollView(animated: false)
          self.scrollView.zoomScale = 1.0
          self.addAVPlayer(videoUrl: localVideoUrl)
        }
      })
    } else {
      self.playerLayer?.removeFromSuperlayer()
      self.urlAsset = nil
      let scale = UIScreen.main.scale
      let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
      imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in

        self.scaleAspectFillSize(image: image!, imageView: self.imageView)
        self.scrollView.contentSize = self.imageView.frame.size
        self.imageView.image = image
        self.centerScrollView(animated: false)

      })
    }

  }

  func previewImageFromVideo(videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true

    var time = asset.duration
    time.value = min(time.value, 2)

    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch {
      return nil
    }
  }

  func addAVPlayer(videoUrl: URL) {
    self.playerLayer?.removeFromSuperlayer()
    let player = AVPlayer(url: videoUrl)
    self.playerLayer = AVPlayerLayer(player: player)

    self.playerLayer?.frame = self.imageView.frame
    self.imageView.layer.addSublayer(self.playerLayer!)
    player.play()

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
      if self.allPhotos.count == photosLimit {
        getAllAlbums()
        self.fetchResult = self.allPhotos
      }

    case .smartAlbums:
      if self.allPhotos.count == photosLimit {
        getAllAlbums()
        let collection: PHCollection
        collection = smartAlbums.object(at: indexPath.row)
        guard let assetCollection = collection as? PHAssetCollection
          else { fatalError("expected asset collection") }
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        self.assetCollection = assetCollection

      }

    case .userCollections:
      if self.allPhotos.count == photosLimit {
        getAllAlbums()
        let collection: PHCollection
        collection = userCollections.object(at: indexPath.row)
        guard let assetCollection = collection as? PHAssetCollection
          else { fatalError("expected asset collection") }
        self.fetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)
        self.assetCollection = assetCollection
      }
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
      if fetchResult.count != 0 {
        let asset = fetchResult.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in

          cell.imageView?.image = image

        })
      }

      return cell

    case .smartAlbums:
      let collection = smartAlbums.object(at: indexPath.row)
      self.smartAlbumsFetchResult = PHAsset.fetchAssets(in: collection, options: nil)
      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      cell.textLabel!.text = collection.localizedTitle
      if smartAlbumsFetchResult.count != 0 {
        let asset = smartAlbumsFetchResult.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in

          cell.imageView?.image = image

        })
      }
      return cell

    case .userCollections:
      let collection = userCollections.object(at: indexPath.row)
      guard let assetCollection = collection as? PHAssetCollection
        else { fatalError("expected asset collection") }
      self.userCollectionsFetchResult = PHAsset.fetchAssets(in: assetCollection, options: nil)

      let cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier.collection.rawValue, for: indexPath)
      cell.textLabel!.text = collection.localizedTitle

      if userCollectionsFetchResult.count != 0 {
        let asset = userCollectionsFetchResult.object(at: 0)
        let scale = UIScreen.main.scale
        let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in

          cell.imageView?.image = image

        })
      }
      return cell
    }
  }

  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return sectionLocalizedTitles[section]
  }
}
