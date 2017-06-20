//
//  CameraViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 18..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
  let capturedImageView = UIImageView()
  var session = AVCaptureSession()
  var camera: AVCaptureDevice?
  var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
  var cameraCaptureOutput = AVCapturePhotoOutput()

	private let camView = UIView().then {
		$0.backgroundColor = UIColor.black
	}
	private let scrollView = UIScrollView().then {
		$0.backgroundColor = UIColor.yellow
		$0.isPagingEnabled = true
		$0.bounces = false
	}

	private let bottomView = UIView().then {
		$0.backgroundColor = UIColor.green
	}

	private let takePhotoButton = UIButton().then {
		$0.backgroundColor = UIColor.red
		$0.layer.cornerRadius = 30
		$0.addTarget(self, action: #selector(takePhotoButtonDidTap), for: .touchUpInside)
	}

	private let takeVideoButton = UIButton().then {
		$0.backgroundColor = UIColor.red
		$0.layer.cornerRadius = 30
		$0.addTarget(self, action: #selector(takeVideoButtonDidTap), for: .touchUpInside)
	}

	init() {
		super.init(nibName: nil, bundle: nil)

		//cancle 버튼 생성
		self.navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(cancelButtonDidTap)
		)

	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func cancelButtonDidTap() {
		self.dismiss(animated: true, completion: nil)
	}

	func doneButtonDidTap() {

    let postEditorViewController = PostEditorViewController(image: self.capturedImageView.image!)
    self.navigationController?.pushViewController(postEditorViewController, animated: true)
    self.capturedImageView.removeFromSuperview()
    self.navigationItem.rightBarButtonItem = nil
  }

	override func viewDidLoad() {
		super.viewDidLoad()

		self.scrollView.delegate = self
		self.title = "Photo"
		NotificationCenter.default.addObserver(self, selector: #selector(photoModeSetting), name: Notification.Name("photoMode"), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(videoModeSetting), name: Notification.Name("videoMode"), object: nil)
		self.bottomView.addSubview(takePhotoButton)
		self.bottomView.addSubview(takeVideoButton)
		self.scrollView.addSubview(bottomView)
		self.view.addSubview(camView)
		self.view.addSubview(scrollView)

		self.camView.snp.makeConstraints { make in
			make.left.right.equalTo(self.view)
			make.bottom.equalTo(self.scrollView.snp.top)
			make.height.equalTo(self.camView.snp.width)
		}

		self.scrollView.snp.makeConstraints { make in
			make.left.right.equalTo(self.view)
		}

		self.scrollView.snp.makeConstraints { make in
			make.height.equalTo(667 - 44 - 375 - 50)
		}

		self.bottomView.snp.makeConstraints { make in
			make.width.equalTo(self.view.bounds.width * 2)
			make.height.equalTo(self.scrollView.snp.height)
			make.centerY.equalTo(self.scrollView.snp.centerY)
			make.centerX.equalTo(self.view.bounds.width)
		}

		self.takePhotoButton.snp.makeConstraints { make in
			make.center.equalTo(self.scrollView.snp.center)
			make.height.width.equalTo(60)
		}

		self.takeVideoButton.snp.makeConstraints { make in
			make.centerX.equalTo(self.view.frame.width * 3/2)
			make.centerY.equalTo(self.scrollView.snp.centerY)
			make.width.height.equalTo(60)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		self.camView.snp.makeConstraints { make in
			make.top.equalTo((self.navigationController?.navigationBar.snp.bottom)!)
		}

		DispatchQueue.main.async {
			self.scrollView.contentSize = self.bottomView.bounds.size
		}
    initializeCaptureSession()
  }

  func displayCapturPhoto() {

    //capturedImageView.contentMode = .scaleAspectFill
    capturedImageView.frame = self.camView.bounds
    self.camView.addSubview(capturedImageView)
  }

  func savePhotoInLibrary() {
    UIImageWriteToSavedPhotosAlbum(self.capturedImageView.image!, nil, nil, nil)
  }

  func initializeCaptureSession() {
    session.sessionPreset = AVCaptureSessionPresetHigh
    camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    do {
      let cameraCaptureInput = try AVCaptureDeviceInput(device: camera!)
      cameraCaptureOutput = AVCapturePhotoOutput()
      if session.inputs.isEmpty {
        session.addInput(cameraCaptureInput)
        session.addOutput(cameraCaptureOutput)
      }

    } catch {
      print(error.localizedDescription)
    }
    cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
    cameraPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
    cameraPreviewLayer?.frame = view.bounds
    cameraPreviewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.portrait

    camView.layer.insertSublayer(cameraPreviewLayer!, at: 0)

    session.startRunning()

  }

  func takePhotoButtonDidTap() {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = .off
    cameraCaptureOutput.capturePhoto(with: settings, delegate: self)
	}

	func takeVideoButtonDidTap() {

	}

	func photoModeSetting() {

		self.title = "Photo"
		let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
		if page != 0 {
			UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
				self.scrollView.contentOffset.x = 0}, completion: nil)
		}

	}

	func videoModeSetting() {
		self.title = "Video"
		let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
		if page != 1 {
			UIView.animate(withDuration: 0.5, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
				self.scrollView.contentOffset.x = self.scrollView.bounds.size.width}, completion: nil)
		}

	}

}

extension CameraViewController: UIScrollViewDelegate {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
		if page == 0 {
			photoModeSetting()
			NotificationCenter.default.post(name: Notification.Name("photoModeOnTabBar"), object: nil)
		} else if page == 1 {
			videoModeSetting()
			NotificationCenter.default.post(name: Notification.Name("videoModeOnTabBar"), object: nil)
		}
	}
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {

  func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {

    if let unwrappedError = error {
      print(unwrappedError.localizedDescription)
    } else {

      if let sampleBuffer = photoSampleBuffer, let dataImage = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) {

        if let finalImage = UIImage(data: dataImage) {
          capturedImageView.image = finalImage
          displayCapturPhoto()
          savePhotoInLibrary()
          //done 버튼 생성
          self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonDidTap)
          )
        }
      }
    }
  }

}
