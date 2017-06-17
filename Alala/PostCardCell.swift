

import UIKit

class PostCardCell: UICollectionViewCell {

    fileprivate let photoView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(self.photoView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ imageString: String) {

        self.photoView.image = UIImage(named: imageString)
        self.photoView.contentMode = .scaleAspectFit
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.photoView.frame = self.contentView.bounds
    }
    
}
