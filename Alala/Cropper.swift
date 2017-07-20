//
//  Cropper.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 19..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVFoundation

struct Cropper {
  func cropVideo( _ outputFileUrl: URL, callback: @escaping ( _ newUrl: URL ) -> Void ) {

    let videoAsset: AVAsset = AVAsset( url: outputFileUrl )
    let clipVideoTrack = videoAsset.tracks( withMediaType: AVMediaTypeVideo ).first! as AVAssetTrack

    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = CGSize( width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height )
    videoComposition.frameDuration = CMTimeMake( 1, 60 )

    let transformer = AVMutableVideoCompositionLayerInstruction( assetTrack: clipVideoTrack )
    let transform1 = CGAffineTransform( translationX: clipVideoTrack.naturalSize.height, y: -( clipVideoTrack.naturalSize.width - clipVideoTrack.naturalSize.height ) / 2 )
    let transform2 = transform1.rotated(by: .pi/2 )
    transformer.setTransform( transform2, at: kCMTimeZero)

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds( 60, 60 ) )

    instruction.layerInstructions = [transformer]
    videoComposition.instructions = [instruction]

    let fileManager = FileManager()
    let croppedOutputFileUrl = URL(fileURLWithPath: fileManager.getOutputPath(String.randomAlphaNumericString(length: 10)))
    let exporter = AVAssetExportSession(asset: videoAsset, presetName: AVAssetExportPresetHighestQuality)!
    exporter.videoComposition = videoComposition
    exporter.outputURL = croppedOutputFileUrl
    exporter.outputFileType = AVFileTypeQuickTimeMovie

    exporter.exportAsynchronously( completionHandler: { () -> Void in
      DispatchQueue.main.async(execute: {
        callback( croppedOutputFileUrl )
      })
    })
  }

  func cropImage(image: UIImage, scrollView: UIScrollView, imageView: UIImageView, cropAreaView: UIView) -> UIImage? {

    let factor = image.size.width/UIScreen.main.bounds.width
    let scale = 1/scrollView.zoomScale
    let imageFrame = imageView.imageFrame(image: image)
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
      rect.origin.x = imageView.imageFrame(image: image).origin.x
      rect.origin.y = (scrollView.contentOffset.y + cropAreaView.frame.origin.y - imageFrame.origin.y) * scale * factor
      rect.size.width = image.size.width
      rect.size.height = cropAreaView.frame.size.height * scale * factor

    } else {
      // 원본
      return image
    }
    return UIImage(cgImage: image.cgImage!.cropping(to: rect)!)
  }
}
