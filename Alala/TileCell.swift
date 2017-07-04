import UIKit

class TileCell: UICollectionViewCell {

  var representedAssetIdentifier: String!

  fileprivate let imageView = UIImageView()

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(self.imageView)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  var thumbnailImage: UIImage! {
    didSet {
      imageView.image = thumbnailImage
    }
  }

  // MARK: Configuring
  func configure(photo: UIImage) {
    self.imageView.image = photo
    self.imageView.contentMode = .scaleAspectFill
    self.imageView.clipsToBounds = true
  }

  override var isSelected: Bool {
    didSet {
      self.layer.borderWidth = 3.0
      self.layer.borderColor = isSelected ? UIColor.blue.cgColor : UIColor.clear.cgColor
    }
  }

  // MARK: Size
  class func size(width: CGFloat) -> CGSize {
    return CGSize(width: width, height: width) // 정사각형
  }

  // MARK: Layout
  override func layoutSubviews() {
    super.layoutSubviews()
    self.imageView.frame = self.contentView.bounds
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    thumbnailImage = nil
  }

}
