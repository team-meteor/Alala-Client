import UIKit
import Photos
import AVKit

class SelectionViewController: UIViewController {
  var playerLayer: AVPlayerLayer?
  var player: AVPlayer?
  var playerItem: AVPlayerItem?
  var imageArr = [UIImage]()
  var urlAssetArr = [AVURLAsset]()

  var zoomMode: Bool = false
  var isZooming: Bool = false
  let photosLimit: Int = 500
  var getImageView: UIImageView?
  var getImage: UIImage?

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

  let initialRequestOptions = PHImageRequestOptions().then {
    $0.isSynchronous = true
    $0.resizeMode = .fast
    $0.deliveryMode = .fastFormat
  }

  fileprivate let tableView = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.allPhotos.rawValue)
    $0.register(GridViewCell.self, forCellReuseIdentifier: CellIdentifier.collection.rawValue)
  }
  fileprivate let libraryButton = UIButton().then {
    $0.backgroundColor = UIColor.red
    $0.setTitle("Library v", for: .normal)
  }
  fileprivate let playButton = UIButton().then {
    $0.backgroundColor = UIColor.blue
    $0.setTitle("Pause", for: UIControlState.normal)
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
    $0.minimumZoomScale = 0.7
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
    $0.allowsMultipleSelection = true
  }
  fileprivate let cropAreaView = UIView().then {
    $0.isUserInteractionEnabled = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 1 / UIScreen.main.scale
  }
  fileprivate let buttonBarView = UIView().then {
    $0.backgroundColor = UIColor.clear
  }
  fileprivate let scrollViewZoomButton = Button()
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
    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.baseScrollView.delegate = self
    self.scrollView.delegate = self
    self.tableView.delegate = self
    self.tableView.dataSource = self

    self.configureView()
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
    prepareMultiparts { _ in

      let croppedImage = self.getCropImage()
      let postEditorViewController = PostEditorViewController(image: croppedImage)
      postEditorViewController.imageArr = self.imageArr
      postEditorViewController.urlAssetArr = self.urlAssetArr
      self.navigationController?.pushViewController(postEditorViewController, animated: true)
    }
  }

  func prepareMultiparts(completion: @escaping (_ success: Bool) -> Void) {

    if self.collectionView.indexPathsForSelectedItems?.count != 0 {

      for index in self.collectionView.indexPathsForSelectedItems! {
        let asset = self.fetchResult.object(at: index.item)

        if asset.mediaType == .video {
          self.imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: {(asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
              self.urlAssetArr.append(urlAsset)

            }
          })
        } else {
          let scale = UIScreen.main.scale
          let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
          self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: self.initialRequestOptions, resultHandler: { image, _ in
            self.imageArr.append(image!)

          })
        }
      }
    }
    completion(true)
  }

  func libraryButtonDidTap() {
    if libraryButton.currentTitle == "Library v" {
      if self.allPhotos.count == photosLimit {
        getAllAlbums()

        self.tableView.reloadData()

      }
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
    self.imageView.frame.size = CGSize(width: imageWidth, height: imageHeight)
  }

  func configureView() {

    let screenWidth = self.view.bounds.width
    let screenHeight = self.view.bounds.height
    let navigationBarHeight = self.navigationController?.navigationBar.frame.height
    let bounds = self.navigationController!.navigationBar.bounds
    self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: bounds.width, height: 44)
    self.title = "Library"

    self.baseScrollView.contentSize = CGSize(width: screenWidth, height: screenHeight * 2 / 3 + screenHeight - screenWidth/8 * 2 - navigationBarHeight!)

    self.buttonBarView.addSubview(scrollViewZoomButton)
    self.baseScrollView.addSubview(self.scrollView)
    self.baseScrollView.addSubview(self.cropAreaView)
    self.baseScrollView.addSubview(self.collectionView)
    self.baseScrollView.addSubview(self.buttonBarView)
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
      make.height.equalTo(screenHeight * 2 / 3 - screenWidth/8 )
      make.width.equalTo(screenWidth)
    }
    self.collectionView.snp.makeConstraints { make in
      make.left.bottom.right.equalTo(self.baseScrollView)
      make.top.equalTo(self.scrollView.snp.bottom)
      make.height.equalTo(screenHeight - screenWidth/8 - navigationBarHeight!)
      make.width.equalTo(screenWidth)
    }
    self.cropAreaView.snp.makeConstraints { make in
      make.edges.equalTo(self.scrollView)
    }
    self.buttonBarView.snp.makeConstraints { make in
      make.left.right.equalTo(self.baseScrollView)
      make.bottom.equalTo(self.collectionView.snp.top)
      make.height.equalTo(screenWidth/8)
      make.width.equalTo(screenWidth)
    }
    self.scrollViewZoomButton.snp.makeConstraints { make in
      make.width.equalTo(screenWidth/12)
      make.height.equalTo(screenWidth/12)
      make.centerY.equalTo(self.buttonBarView)
      make.left.equalTo(self.buttonBarView).offset(10)
    }

    self.scrollViewZoomButton.addTarget(self, action: #selector(scrollViewZoom), for: .touchUpInside)
    self.libraryButton.addTarget(self, action: #selector(libraryButtonDidTap), for: .touchUpInside)
    self.playButton.addTarget(self, action: #selector(self.playButtonDidTap), for: .touchUpInside)
  }

  func scrollViewZoom() {
    if(zoomMode) {
      if(isZooming) {
        aspectFitMode()
        zoomMode = true
        isZooming = false
      } else {
        aspectFillMode()
        zoomMode = false
      }
    } else {
      if(isZooming) {
        aspectFillMode()
        zoomMode = false
        isZooming = false
      } else {
        aspectFitMode()
        zoomMode = true
      }

    }

  }

  func aspectFillMode() {
    scaleAspectFillSize(image: getImage!, imageView: getImageView!)
    self.scrollView.contentSize = self.imageView.frame.size
    self.centerScrollView(animated: false)
  }
  func aspectFitMode() {
    imageView.frame.size = cropAreaView.frame.size
    self.scrollView.contentSize = self.imageView.frame.size
    imageView.contentMode = .scaleAspectFit
    self.centerScrollView(animated: false)
  }

  func addAVPlayer(videoUrl: URL) {
    self.cropAreaView.isUserInteractionEnabled = true
    playerItem = AVPlayerItem(url: videoUrl)
    player = AVPlayer(playerItem: playerItem)
    self.playerLayer = AVPlayerLayer(player: player)
    DispatchQueue.main.async {
      self.setConstraintOfPlayer()
    }

  }

  func setConstraintOfPlayer() {
    self.imageView.layer.addSublayer(self.playerLayer!)
    self.playerLayer!.frame = self.imageView.frame
    self.cropAreaView.addSubview(self.playButton)
    self.playButton.snp.makeConstraints { make in
      make.center.equalTo(self.cropAreaView)
      make.width.height.equalTo(50)
    }
  }

  func playButtonDidTap() {

    if player?.rate == 0 {
      player!.play()

      playButton.setTitle("Pause", for: UIControlState.normal)
    } else {
      player!.pause()

      playButton.setTitle("Play", for: UIControlState.normal)
    }
  }

}

extension SelectionViewController: UICollectionViewDelegate {
  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    if self.allPhotos.count == photosLimit && self.fetchResult == self.allPhotos {
      DispatchQueue.global().async {
        self.getAllAlbums()

        print("fetch")
        DispatchQueue.main.async {
          self.fetchResult = self.allPhotos
          self.collectionView.reloadData()
        }
      }
    }
  }

  func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
    if let selectedItems = collectionView.indexPathsForSelectedItems {
      if selectedItems.contains(indexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)

        return false
      }
    }
    return true
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

      if asset == self.fetchResult.object(at: 0) && self.imageView.image == nil {
        self.getImageView = self.imageView
        self.getImage = image
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

          let localVideoUrl: URL = urlAsset.url as URL
          let previewImage = self.previewImageFromVideo(videoUrl: localVideoUrl)

          self.scaleAspectFillSize(image: previewImage!, imageView: self.imageView)
          self.scrollView.contentSize = self.imageView.frame.size
          self.imageView.image = previewImage
          self.centerScrollView(animated: false)
          self.addAVPlayer(videoUrl: localVideoUrl)
          self.player?.play()
        }
      })
    } else {
      self.playerLayer?.removeFromSuperlayer()
      self.playButton.removeFromSuperview()
      self.cropAreaView.isUserInteractionEnabled = false
      let scale = UIScreen.main.scale
      let targetSize = CGSize(width: 600 * scale, height: 600 * scale)

      imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: initialRequestOptions, resultHandler: { image, _ in
        self.getImageView = self.imageView
        self.getImage = image

        if(self.zoomMode) {
          self.aspectFitMode()
        } else {
          self.aspectFillMode()
        }
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

  func playerDidFinishPlaying(note: NSNotification) {
    self.playerLayer?.removeFromSuperlayer()
    self.playButton.removeFromSuperview()
    self.cropAreaView.isUserInteractionEnabled = false
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
    self.cropAreaView.backgroundColor = UIColor.black.withAlphaComponent(page / 600)
  }
  func scrollViewDidZoom(_ scrollView: UIScrollView) {
    isZooming = true
  }
}

extension SelectionViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 100
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    switch Section(rawValue: indexPath.section)! {

    case .allPhotos:

      self.fetchResult = self.allPhotos

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
