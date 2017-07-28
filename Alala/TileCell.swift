import UIKit

class TileCell: UICollectionViewCell {

  var representedAssetIdentifier: String!
  static let cellReuseIdentifier = "TileCell"

  let thumbnailImageView = UIImageView().then {
    $0.backgroundColor = .lightGray
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  let rightTopIconView = UIImageView()

  override init(frame: CGRect) {
    isVideo = false
    super.init(frame: frame)

    self.contentView.addSubview(thumbnailImageView)
    self.contentView.addSubview(rightTopIconView)

    thumbnailImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView)
      make.left.equalTo(self.contentView)
      make.right.equalTo(self.contentView)
      make.bottom.equalTo(self.contentView)
    }

    rightTopIconView.snp.makeConstraints { (make) in
      make.top.equalTo(thumbnailImageView).offset(5)
      make.right.equalTo(thumbnailImageView).offset(-5)
      make.width.equalTo(20)
      make.height.equalTo(20)
    }
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Configuring
  func configure(photo: UIImage) {

    self.thumbnailImageView.image = photo
    self.thumbnailImageView.contentMode = .scaleAspectFill
    self.thumbnailImageView.clipsToBounds = true

  }

  override var isSelected: Bool {
    didSet {
      self.layer.borderWidth = 3.0
      self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
      self.backgroundColor = UIColor.white.withAlphaComponent(50)
    }
  }

  // MARK: Size
  class func size(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: width) // 정사각형
  }

  // MARK: Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    self.thumbnailImageView.frame = self.contentView.bounds
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailImageView.image = nil
  }

  var isVideo: Bool {
    didSet {
      switch isVideo {
      case true:
        rightTopIconView.isHidden = false
        rightTopIconView.image = UIImage(named: "video1")?.resizeImage(scaledTolength: 20)
      case false:
        rightTopIconView.isHidden = true
      }
    }
  }

}
