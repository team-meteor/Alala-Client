//
//  UIImageExtension.swift
//  Alala
//
//  Created by hoemoon on 09/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

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
