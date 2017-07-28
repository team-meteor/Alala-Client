import UIKit

class TileCell: UICollectionViewCell {

  var representedAssetIdentifier: String!
  static let cellReuseIdentifier = "TileCell"

  let thumbnailImageView = UIImageView().then {
    $0.backgroundColor = .lightGray
    $0.contentMode = .scaleAspectFill
    $0.clipsToBounds = true
  }

  let rightBottomDurationLabel = UILabel().then {
    $0.textColor = UIColor.white
    $0.font = $0.font.withSize(15)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    self.contentView.addSubview(thumbnailImageView)
    self.contentView.addSubview(rightBottomDurationLabel)
    thumbnailImageView.snp.makeConstraints { (make) in
      make.top.equalTo(self.contentView)
      make.left.equalTo(self.contentView)
      make.right.equalTo(self.contentView)
      make.bottom.equalTo(self.contentView)
    }

    rightBottomDurationLabel.snp.makeConstraints { (make) in
      make.bottom.equalTo(thumbnailImageView).offset(-2)
      make.right.equalTo(thumbnailImageView).offset(-2)
      make.width.equalTo(50)
      make.height.equalTo(50)
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
    rightBottomDurationLabel.text = nil
  }

  func setVideoLabel(duration: Float) {
    let time = timeString(time: duration)
    rightBottomDurationLabel.text = time
  }

  func timeString(time: Float) -> String {
    let minutes = Int(time) / 60 % 60
    let seconds = Int(time) % 60
    return String(format:"%02i:%02i", minutes, seconds)
  }

}
