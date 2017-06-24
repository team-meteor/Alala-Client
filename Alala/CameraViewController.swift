//
//  CameraViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 24..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class CameraViewController: UIViewController {
  let capturedImageView = UIImageView()
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var activeInput: AVCaptureDeviceInput!
  var imageOutput: AVCapturePhotoOutput!

  let switchButton = UIButton().then {
    $0.backgroundColor = UIColor.blue
    $0.setTitle("switch", for: .normal)
    $0.addTarget(self, action: #selector(switchButtonDidTap), for: .touchUpInside)
  }

  private let camPreview = UIView().then {
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
    stopSession()
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
    NotificationCenter.default.addObserver(self, selector: #selector(stopSession), name: Notification.Name("cameraStop"), object: nil)
    self.bottomView.addSubview(takePhotoButton)
    self.bottomView.addSubview(takeVideoButton)
    self.scrollView.addSubview(bottomView)
    self.view.addSubview(camPreview)
    self.view.addSubview(scrollView)
    self.camPreview.addSubview(switchButton)

    self.camPreview.snp.makeConstraints { make in
      make.left.right.equalTo(self.view)
      make.bottom.equalTo(self.scrollView.snp.top)
      make.height.equalTo(self.camPreview.snp.width)
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

    self.camPreview.snp.makeConstraints { make in
      make.top.equalTo((self.navigationController?.navigationBar.snp.bottom)!)
    }

    self.switchButton.snp.makeConstraints { make in
      make.center.equalTo(self.camPreview)
    }

    DispatchQueue.main.async {
      self.scrollView.contentSize = self.bottomView.bounds.size
    }
    setupSession()
    setupPreview()
  }

  func takeVideoButtonDidTap() {

  }

  func photoModeSetting() {

    startSession()
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

  override var prefersStatusBarHidden: Bool {
    return true
  }

  func setupSession() {
    captureSession.sessionPreset = AVCaptureSessionPresetHigh
    let camera = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)

    do {
      let input = try AVCaptureDeviceInput(device: camera)
      if captureSession.canAddInput(input) {
        captureSession.addInput(input)
        activeInput = input
      }
    } catch {
      print("Error setting device input: \(error)")
    }

    if captureSession.canAddOutput(imageOutput) {
      captureSession.addOutput(imageOutput)
    }
  }

  func setupPreview() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = camPreview.bounds
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    camPreview.layer.addSublayer(previewLayer)
  }

  func startSession() {
    if !captureSession.isRunning {
      videoQueue().async {
        self.captureSession.startRunning()
      }

    }
  }

  func stopSession() {
    if captureSession.isRunning {
      videoQueue().async {
        self.captureSession.stopRunning()
      }
    }
  }

  func videoQueue() -> DispatchQueue {
    return DispatchQueue.global()
  }

  func switchButtonDidTap() {
    let deviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInDualCamera, AVCaptureDeviceType.builtInTelephotoCamera, AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.unspecified)
    if (deviceDiscoverySession?.devices.count)! > 1 {
      var newPosition: AVCaptureDevicePosition!
      if activeInput.device.position == AVCaptureDevicePosition.back {
        newPosition = AVCaptureDevicePosition.front
      } else {
        newPosition = AVCaptureDevicePosition.back
      }

      var newCamera: AVCaptureDevice!
      let devices = deviceDiscoverySession?.devices
      for device in devices! where device.position == newPosition { newCamera = device }

      do {
        let input = try AVCaptureDeviceInput(device: newCamera)
        captureSession.beginConfiguration()
        captureSession.removeInput(activeInput)
        if captureSession.canAddInput(input) {
          captureSession.addInput(input)
          activeInput = input
        } else {
          captureSession.addInput(activeInput)
        }
        captureSession.commitConfiguration()
      } catch {
        print("Error switching cameras: \(error)")
      }
    }
  }

  func displayCapturPhoto() {

    capturedImageView.frame = self.camPreview.bounds
    self.camPreview.addSubview(capturedImageView)
  }

  func takePhotoButtonDidTap() {
    let settings = AVCapturePhotoSettings()
    settings.flashMode = .off
    imageOutput.capturePhoto(with: settings, delegate: self)
  }

  func savePhotoToLibrary() {
    UIImageWriteToSavedPhotosAlbum(self.capturedImageView.image!, nil, nil, nil)
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

          self.capturedImageView.image = finalImage

          displayCapturPhoto()
          savePhotoToLibrary()
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
