import UIKit
import Photos

class SelectionViewController: UIViewController {
  var fetchResult: PHFetchResult<PHAsset>!
  let imageManager = PHCachingImageManager()
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
  override var prefersStatusBarHidden: Bool {
    return true
  }
  override func viewDidLoad() {
    super.viewDidLoad()
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
    fetchAllPhotos()
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
  }
  func centerScrollView(animated: Bool) {
    let targetContentOffset = CGPoint(
      x: (self.scrollView.contentSize.width - self.scrollView.bounds.width) / 2,
      y: (self.scrollView.contentSize.height - self.scrollView.bounds.height) / 2
    )
    self.scrollView.setContentOffset(targetContentOffset, animated: animated)
  }
  func fetchAllPhotos() {
    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    fetchResult = PHAsset.fetchAssets(with: allPhotosOptions)
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

}

extension SelectionViewController: UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "tileCell", for: indexPath) as! TileCell
    let asset = fetchResult.object(at: indexPath.item)
    cell.representedAssetIdentifier = asset.localIdentifier
    //메타데이터를 이미지로 변환
    let scale = UIScreen.main.scale
    let targetSize = CGSize(width: 600 * scale, height: 600 * scale)
    imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { image, _ in
      if cell.representedAssetIdentifier == asset.localIdentifier {
        cell.configure(photo: image!)
      }
      if asset == self.fetchResult.object(at: 0) {
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
