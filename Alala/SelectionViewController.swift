import UIKit
import Photos
import AVKit

class SelectionViewController: UIViewController {

  var playerLayer: AVPlayerLayer?
  var player: AVPlayer?
  var playerItem: AVPlayerItem?
  var imageArr = [UIImage]()
  var urlAssetArr = [AVURLAsset]()
  var photoAlbum = PhotoAlbum.sharedInstance

  var zoomMode: Bool = false
  var multiSelectMode: Bool = false
  let photosLimit: Int = 500
  var getImageView: UIImageView?
  var getImage: UIImage?
  var getZoomScale: CGFloat?

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
  var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>() {
    didSet {
      updateFirstImageView()
      self.collectionView.reloadData()
    }
  }
  var smartAlbumsFetchResult: PHFetchResult<PHAsset>!
  var smartAlbumsArr = [PHAssetCollection]()
  var userCollectionsFetchResult: PHFetchResult<PHAsset>!
  var userAlbumsArr = [PHAssetCollection]()
  var assetCollection: PHAssetCollection?
  let imageManager = PHCachingImageManager()
  let tileCellSpacing = CGFloat(1)
  let sectionLocalizedTitles = ["", NSLocalizedString("Smart Albums", comment: ""), NSLocalizedString("Albums", comment: "")]

  let initialRequestOptions = PHImageRequestOptions().then {
    $0.isSynchronous = true
    $0.resizeMode = .fast
    $0.deliveryMode = .fastFormat
  }
  fileprivate var tableWrapperVC: TableViewWrapperController?
  fileprivate let libraryButton = UIButton().then {
    $0.backgroundColor = UIColor.red
    $0.setTitle("Library v", for: .normal)
  }
  fileprivate let playButton = UIButton().then {
    $0.backgroundColor = UIColor.blue
    $0.setTitle("Pause", for: UIControlState.normal)
  }
  fileprivate let multiSelectButton = MultiSelectButton()

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
    $0.minimumZoomScale = 0.8
    $0.zoomScale = 1.0
    $0.bouncesZoom = true
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
    $0.allowsMultipleSelection = false
    $0.showsVerticalScrollIndicator = true
  }

  fileprivate let cropAreaView = UIView().then {
    $0.isUserInteractionEnabled = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.layer.borderWidth = 1 / UIScreen.main.scale
  }
  fileprivate let buttonBarView = UIView().then {
    $0.backgroundColor = UIColor.clear
  }
  fileprivate let scrollViewZoomButton = ZoomButton()
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelButtonDidTap)
    )

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

    let scrollViewDoubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapped))
    scrollViewDoubleTap.numberOfTapsRequired = 2
    scrollView.addGestureRecognizer(scrollViewDoubleTap)

    NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)

    NotificationCenter.default.addObserver(self, selector: #selector(fetchSmartUserAlbums), name: NSNotification.Name(rawValue: "fetchSmartUserAlbums"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(fetchAllPhotoAlbum), name: NSNotification.Name(rawValue: "fetchAllPhotoAlbum"), object: nil)

    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    self.baseScrollView.delegate = self
    self.scrollView.delegate = self

    self.configureView()
    photoAlbum.getLimitedPhotos()
    self.allPhotos = photoAlbum.allPhotos

    self.fetchResult = allPhotos
  }
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.navigationItem.rightBarButtonItem?.isEnabled = true
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
    NotificationCenter.default.post(name: Notification.Name("dismissWrapperVC"), object: nil)
  }

  func cropImage(image: UIImage) -> UIImage? {

    let factor = imageView.image!.size.width/view.frame.width
    let scale = 1/scrollView.zoomScale
    let imageFrame = imageView.imageFrame()
    let imageWidth = image.size.width
    let imageHeight = image.size.height
    var rect = CGRect()

    if (imageWidth > imageHeight && scrollView.zoomScale == 1.0) || (imageWidth < imageHeight && scrollView.zoomScale == 1.0) {
      // 1:1
      rect.origin.x = (scrollView.contentOffset.x + cropAreaView.frame.origin.x - imageFrame.origin.x) * scale * factor
      rect.origin.y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
      rect.size.width = cropAreaView.frame.size.width * scale * factor
      rect.size.height = cropAreaView.frame.size.height * scale * factor

    } else if imageWidth < imageHeight && scrollView.zoomScale == 0.8 {
      // 0.8 좌우 여백
      rect.origin.x = self.imageView.imageFrame().origin.x
      rect.origin.y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
      rect.size.width = (self.imageView.image?.size.width)!
      rect.size.height = cropAreaView.frame.size.height * scale * factor

    } else {
      // 원본
      return image
    }

    return UIImage(cgImage: image.cgImage!.cropping(to: rect)!)

  }

  func doneButtonDidTap() {
    if self.collectionView.indexPathsForSelectedItems?.count != 0 {
      self.navigationItem.rightBarButtonItem?.isEnabled = false
      prepareMultiparts { _ in

        let croppedImage = self.cropImage(image: self.imageView.image!)
        let postEditorViewController = PostEditorViewController(image: croppedImage!)
        postEditorViewController.imageArr = self.imageArr
        postEditorViewController.urlAssetArr = self.urlAssetArr
        self.navigationController?.pushViewController(postEditorViewController, animated: true)
      }
    }
  }

  func doubleTapped() {
    if scrollView.zoomScale == 1.0 {
      scrollView.setZoomScale(0.8, animated: true)
      zoomMode = true
    } else {
      scrollView.setZoomScale(1.0, animated: true)
      zoomMode = false
    }

  }

  func prepareMultiparts(completion: @escaping (_ success: Bool) -> Void) {
    self.imageArr = []
    self.urlAssetArr = []

    if self.collectionView.indexPathsForSelectedItems?.count != 0 {

      for index in self.collectionView.indexPathsForSelectedItems! {
        let asset = self.fetchResult.object(at: index.item)

        if asset.mediaType == .video {
          self.imageManager.requestAVAsset(forVideo: asset, options: nil, resultHandler: {(asset: AVAsset?, _: AVAudioMix?, _: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
              self.urlAssetArr.append(urlAsset)
              print("video", self.urlAssetArr)
              if self.urlAssetArr.count + self.imageArr.count == self.collectionView.indexPathsForSelectedItems?.count {
                completion(true)
              }
            }
          })
        } else {
          self.imageManager.requestImage(
            for: asset,
            targetSize: CGSize(width: 600 * UIScreen.main.scale, height: 600 * UIScreen.main.scale),
            contentMode: .aspectFit,
            options: self.initialRequestOptions,
            resultHandler: { image, _ in
              let croppedImage = self.cropImage(image: image!)
              self.imageArr.append(croppedImage!)
              print("image", self.imageArr )
              if self.urlAssetArr.count + self.imageArr.count == self.collectionView.indexPathsForSelectedItems?.count {
                completion(true)
              }
          })
        }
      }
    }
  }

  func updateFirstImageView() {
    let screenWidth = self.view.bounds.width
    let screenHeight = self.view.bounds.height
    let scale = UIScreen.main.scale
    let targetSize = CGSize(width:  600 * scale, height: 600 * scale)

    scrollView.frame.size = CGSize(width: screenWidth, height: screenHeight * 2 / 3)

    let asset = self.fetchResult.object(at: 0)
    self.imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: self.initialRequestOptions, resultHandler: { image, _ in

      if image != nil {
        self.getImage = image!
        self.scrollView.zoomScale = 1.0
        self.scaleAspectFillSize(image: image!, imageView: self.imageView)
        self.scrollView.contentSize = self.imageView.frame.size
        self.imageView.image = image
        self.centerScrollView(animated: false)
      }
    })

  }

  func libraryButtonDidTap() {
    if libraryButton.currentTitle == "Library v" {
      if allPhotos.count == photosLimit {

        photoAlbum.getAllPhotos()
      }
      if smartAlbums == nil || userCollections == nil {

        photoAlbum.getSmartUserAlbums()

      }
      tableViewOnMode()
    } else if libraryButton.currentTitle == "Library ^" {
      tableViewOffMode()
    }
  }

  func fetchSmartUserAlbums() {
    self.smartAlbumsArr = photoAlbum.smartAlbumsArr
    self.userAlbumsArr = photoAlbum.userAlbumsArr
  }

  func fetchAllPhotoAlbum() {
    self.allPhotos = photoAlbum.allPhotos
    self.fetchResult = self.allPhotos
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
    } else {
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
    self.buttonBarView.addSubview(multiSelectButton)
    self.baseScrollView.addSubview(self.scrollView)
    self.baseScrollView.addSubview(self.cropAreaView)
    self.baseScrollView.addSubview(self.collectionView)
    self.baseScrollView.addSubview(self.buttonBarView)
    self.scrollView.addSubview(self.imageView)
    self.view.addSubview(baseScrollView)
    //self.view.addSubview(self.wrapperView!)

    //constraints
//    self.wrapperView?.snp.makeConstraints { make in
//      make.width.equalTo(self.view)
//      make.height.equalTo(self.view.frame.height - 44)
//      make.centerX.equalTo(self.view)
//      make.top.equalTo(self.view.snp.bottom)
//    }
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
    self.multiSelectButton.snp.makeConstraints { make in
      make.width.equalTo(screenWidth/12)
      make.height.equalTo(screenWidth/12)
      make.centerY.equalTo(self.buttonBarView)
      make.right.equalTo(self.buttonBarView).offset(-10)
    }
    self.scrollViewZoomButton.addTarget(self, action: #selector(scrollViewZoom), for: .touchUpInside)
    self.multiSelectButton.addTarget(self, action: #selector(multiSelectButtonDidTap), for: .touchUpInside)
    self.libraryButton.addTarget(self, action: #selector(libraryButtonDidTap), for: .touchUpInside)
    self.playButton.addTarget(self, action: #selector(self.playButtonDidTap), for: .touchUpInside)
  }

  func scrollViewZoom() {

    if scrollView.zoomScale >= 1.0 {
      scrollView.setZoomScale(0.8, animated: true)
      zoomMode = true
    } else {
      scrollView.setZoomScale(1.0, animated: true)
      zoomMode = false
    }

  }

  func multiSelectButtonDidTap() {
    if multiSelectMode {
      collectionView.allowsMultipleSelection = false
      multiSelectMode = false
      scrollViewZoomButton.isHidden = false
      zoomMode = true
      scrollView.isUserInteractionEnabled = true
    } else {
      collectionView.allowsMultipleSelection = true
      multiSelectMode = true
      scrollViewZoomButton.isHidden = true
      if scrollView.zoomScale != 1.0 {
        scrollView.setZoomScale(1.0, animated: true)
      }
      zoomMode = false
      scrollView.isUserInteractionEnabled = false
    }
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
  deinit {
    NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    print("selection deinit")
  }

  func tableViewOffMode() {
    self.libraryButton.setTitle("Library v", for: .normal)

    self.tableWrapperVC?.dismiss(animated: true, completion: nil)
    //    UIView.animate(withDuration: 0.5, animations: {
    //      self.wrapperView?.transform = CGAffineTransform(translationX: 0, y: (self.wrapperView?.frame.height)!)
    //    })
    NotificationCenter.default.post(name: Notification.Name("showCustomTabBar"), object: nil)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelButtonDidTap)
    )

    self.navigationItem.rightBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(doneButtonDidTap)
    )
  }

  func tableViewOnMode() {
    self.libraryButton.setTitle("Library ^", for: .normal)
    tableWrapperVC = TableViewWrapperController()

    self.present(tableWrapperVC!, animated: true, completion: nil)

    //    UIView.animate(withDuration: 0.5, animations: {self.tableWrapperVC?.view.transform = CGAffineTransform(translationX: 0, y: -((self.tableWrapperVC!.view.frame.height)))})
    NotificationCenter.default.post(name: Notification.Name("hideCustomTabBar"), object: nil)
    self.navigationItem.leftBarButtonItem = nil
    self.navigationItem.rightBarButtonItem = nil
  }

}

extension SelectionViewController: UICollectionViewDelegate {

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

    if self.allPhotos.count == photosLimit && self.fetchResult == self.allPhotos {

      photoAlbum.getAllPhotos()

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
    let targetSize = CGSize(width:  100 * scale, height: 100 * scale)

    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: initialRequestOptions, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
        cell.configure(photo: image!)
      }

      if asset == self.fetchResult.object(at: 0) && self.imageView.image == nil {
        self.getImage = image
        self.scrollView.zoomScale = 1.0
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
    let cellWidth: CGFloat?
    if(collectionViewWidth >= 375) {
      cellWidth = round((collectionViewWidth - 5 * tileCellSpacing) / 4)
    } else {
      cellWidth = round((collectionViewWidth - 4 * tileCellSpacing) / 3)
    }
    return TileCell.size(width: cellWidth!)
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return tileCellSpacing
  }
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return tileCellSpacing
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    if self.allPhotos.count == photosLimit && self.fetchResult == self.allPhotos {

      photoAlbum.getAllPhotos()

    }

    let asset = fetchResult.object(at: indexPath.item)

    if asset.mediaType == .video {
      self.player?.pause()
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

      setPlayerFinishMode()

      self.baseScrollView.setContentOffset(CGPoint(x:0, y:0), animated: true)

      let scale = UIScreen.main.scale
      let targetSize = CGSize(width: 600 * scale, height: 600 * scale)

      imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: initialRequestOptions, resultHandler: { image, _ in
        self.getImage = image
        self.scrollView.zoomScale = 1.0
        self.scaleAspectFillSize(image: image!, imageView: self.imageView)
        self.scrollView.contentSize = self.imageView.frame.size
        self.imageView.image = image
        self.centerScrollView(animated: false)

        if self.zoomMode {
          self.scrollView.zoomScale = 0.8
        } else {
          self.scrollView.zoomScale = 1.0
        }
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
    setPlayerFinishMode()
  }

  func setPlayerFinishMode() {

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

    let imageViewSize = imageView.frame.size
    let scrollViewSize = scrollView.bounds.size

    let verticalPadding = imageViewSize.height < scrollViewSize.height ?  (scrollViewSize.height - imageViewSize.height) / 2 : 0
    let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0

    scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)

  }
}
