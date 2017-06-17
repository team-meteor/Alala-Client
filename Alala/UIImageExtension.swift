

import UIKit

extension UIImage {
    
	func resizeImage(scaledTolength length: CGFloat) -> UIImage {
		let newSize = CGSize(width: length, height: length)
		UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
		self.draw(in: CGRect(origin: CGPoint.zero, size: CGSize(width: newSize.width, height: newSize.height)))
		let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()
		return newImage
	}
    
}

extension UIImageView {
    
    func setImage(with photoID: String?, placeholder: UIImage? = nil, size: PhotoSize) {
        guard let photoID = photoID else {
            self.image = placeholder
            return
        }
        let url = URL(string: "https://graygram.com/photos/\(photoID)/\(size.pixel)x\(size.pixel)")
        self.kf.setImage(with: url, placeholder: placeholder)
    }
    
}

extension UIImage {
    
    func setImage() -> CGSize {
        let screenWidth: CGFloat = UIScreen.main.bounds.width
        let width = self.size.width
        let height = self.size.height
        
        let ratioValue = screenWidth / width
        let screenHeight: CGFloat = height * ratioValue
        
        return CGSize(width: screenWidth, height: screenHeight)
    }

}
