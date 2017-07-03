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
  var videoData: Data?
  let CaptureModePhoto = 0
  let CaptureModeMovie = 1

  let capturedImageView = UIImageView()
  let captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var activeInput: AVCaptureDeviceInput!
  var imageOutput = AVCapturePhotoOutput()
  var captureMode = Int()
  let movieOutput = AVCaptureMovieFileOutput()

  let switchButton = UIButton().then {
    $0.setImage(UIImage(named: "Camera_Icon")!, for: .normal)
    $0.setTitle("switch", for: .normal)
    $0.addTarget(self, action: #selector(switchButtonDidTap), for: .touchUpInside)
  }
  let buttonBar = UIView().then {
    $0.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
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

  fileprivate let takePhotoButton = UIButton().then {
    $0.setImage(UIImage(named: "Capture_Butt")!, for: .normal)
    $0.addTarget(self, action: #selector(takePhotoButtonDidTap), for: .touchUpInside)
  }

  fileprivate let takeVideoButton = UIButton().then {
    $0.setImage(UIImage(named: "Capture_Butt"), for: .normal)
    $0.addTarget(self, action: #selector(takeVideoButtonDidTap), for: .touchUpInside)
  }

  init() {
    super.init(nibName: nil, bundle: nil)
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .cancel,
      target: self,
      action: #selector(cancelButtonDidTap)
    )
    captureMode = CaptureModePhoto
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func cancelButtonDidTap() {
    stopSession()
    self.dismiss(animated: true, completion: nil)
  }

  func photoDoneButtonDidTap() {
    stopSession()
    let postEditorViewController = PostEditorViewController(image: self.capturedImageView.image!)
    self.navigationController?.pushViewController(postEditorViewController, animated: true)
    self.capturedImageView.removeFromSuperview()
    self.navigationItem.rightBarButtonItem = nil
  }

  func videoDoneButtonDidTap() {
    stopSession()
    let postEditorViewController = PostEditorViewController(image: self.capturedImageView.image!)
    postEditorViewController.videoData = self.videoData!
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
    NotificationCenter.default.addObserver(self, selector: #selector(startSession), name: Notification.Name("cameraStart"), object: nil)
    self.bottomView.addSubview(takePhotoButton)
    self.bottomView.addSubview(takeVideoButton)
    self.scrollView.addSubview(bottomView)
    self.view.addSubview(camPreview)
    self.view.addSubview(scrollView)
    self.camPreview.addSubview(self.buttonBar)
    self.buttonBar.addSubview(switchButton)

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

    self.buttonBar.snp.makeConstraints { make in
      make.left.top.right.equalTo(self.camPreview)
      make.width.equalTo(self.camPreview)
      make.height.equalTo(50)
    }

    self.switchButton.snp.makeConstraints { make in
      make.center.equalTo(self.buttonBar.snp.center)
      make.width.height.equalTo(50)
    }

    DispatchQueue.main.async {
      self.scrollView.contentSize = self.bottomView.bounds.size
    }

    if setupSession() {
      setupPreview()
      setupCaptureMode(CaptureModePhoto)
    }
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

  func setupCaptureMode(_ mode: Int) {
    captureMode = mode
    if mode == CaptureModePhoto {
      // Photo Mode

    } else {
      // Video Mode

    }
  }

  //setup 성공시 true
  func setupSession() -> Bool {
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
      return false
    }

    let microphone = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio)

    do {
      let micInput = try AVCaptureDeviceInput(device: microphone)
      if captureSession.canAddInput(micInput) {
        captureSession.addInput(micInput)
      }
    } catch {
      print("Error setting device audio input: \(error)")
      return false
    }

    if captureSession.canAddOutput(imageOutput) {
      captureSession.addOutput(imageOutput)
    }
    if captureSession.canAddOutput(movieOutput) {
      captureSession.addOutput(movieOutput)
    }
    return true
  }

  func setupPreview() {
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = camPreview.bounds
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    camPreview.layer.addSublayer(previewLayer)
    camPreview.bringSubview(toFront: self.buttonBar)
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
    if movieOutput.isRecording == false {
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
  }

  func displayCapturPhoto() {
    capturedImageView.frame = self.camPreview.bounds
    capturedImageView.contentMode = .scaleAspectFill
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

  func takeVideoButtonDidTap() {
    if movieOutput.isRecording == false {
      let connection = movieOutput.connection(withMediaType: AVMediaTypeVideo)
      if (connection?.isVideoOrientationSupported)! {
        connection?.videoOrientation = currentVideoOrientation()
      }

      if (connection?.isVideoStabilizationSupported)! {
        connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
      }

      let device = activeInput.device
      if (device?.isSmoothAutoFocusSupported)! {
        do {
          try device?.lockForConfiguration()
          device?.isSmoothAutoFocusEnabled = false
          device?.unlockForConfiguration()
        } catch {
          print("Error setting configuration: \(error)")
        }
      }
      let outputURL = tempURL()
      movieOutput.startRecording(toOutputFileURL: outputURL, recordingDelegate: self)
    } else {
      stopRecording()
    }
  }

  func tempURL() -> URL? {
    let directory = NSTemporaryDirectory() as NSString

    if directory != "" {
      let path = directory.appendingPathComponent("penCam.mov")
      return URL(fileURLWithPath: path)
    }
    return nil
  }

  func currentVideoOrientation() -> AVCaptureVideoOrientation {
    var orientation: AVCaptureVideoOrientation

    switch UIDevice.current.orientation {
    case .portrait:
      orientation = AVCaptureVideoOrientation.portrait
    case .landscapeRight:
      orientation = AVCaptureVideoOrientation.landscapeLeft
    case .portraitUpsideDown:
      orientation = AVCaptureVideoOrientation.portraitUpsideDown
    default:
      orientation = AVCaptureVideoOrientation.landscapeRight
    }

    return orientation
  }

  func stopRecording() {
    if movieOutput.isRecording == true {
      movieOutput.stopRecording()
    }
  }

  func saveMovieToLibrary(movieURL: URL) {
    PHPhotoLibrary.shared().performChanges({
      PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: movieURL)
    }) { saved, _ in
      if saved {
        let alertController = UIAlertController(title: "Your video was successfully saved", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        self.present(alertController, animated: true, completion: nil)
      }
    }
  }

}

extension CameraViewController: UIScrollViewDelegate {
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let page = Int(scrollView.contentOffset.x / scrollView.bounds.size.width)
    if page == 0 {
      self.navigationItem.rightBarButtonItem = nil
      self.capturedImageView.removeFromSuperview()
      photoModeSetting()
      NotificationCenter.default.post(name: Notification.Name("photoModeOnTabBar"), object: nil)
    } else if page == 1 {
      self.navigationItem.rightBarButtonItem = nil
      self.capturedImageView.removeFromSuperview()
      videoModeSetting()
      NotificationCenter.default.post(name: Notification.Name("videoModeOnTabBar"), object: nil)
    }
  }
}

extension CameraViewController : AVCapturePhotoCaptureDelegate {

  func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
    let connection = imageOutput.connection(withMediaType: AVMediaTypeVideo)
    if (connection?.isVideoOrientationSupported)! {
      connection?.videoOrientation = currentVideoOrientation()
    }
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
            action: #selector(photoDoneButtonDidTap)
          )
        }
      }
    }
  }
}

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {

  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    takeVideoButton.setImage(UIImage(named: "Capture_Butt1"), for: .normal)
  }

  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    if error != nil {
      print("Error recording movie: \(error!.localizedDescription)")
    } else {
      var movieData: Data?
      do {
        movieData = try Data(contentsOf: outputFileURL)
      } catch _ {
        movieData = nil
        return
      }
      self.videoData = movieData
      self.capturedImageView.image = previewImageFromVideo(videoUrl: outputFileURL)
      displayCapturPhoto()
      saveMovieToLibrary(movieURL: outputFileURL as URL)
      takeVideoButton.setImage(UIImage(named: "Capture_Butt"), for: .normal)
      self.navigationItem.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .done,
        target: self,
        action: #selector(videoDoneButtonDidTap)
      )
    }
  }

  func previewImageFromVideo(videoUrl: URL) -> UIImage? {
    let asset = AVAsset(url: videoUrl)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true

    var time = asset.duration
    time.value = min(time.value, 2)

    do {
      let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
      return UIImage(cgImage: imageRef)
    } catch {
      return nil
    }
  }
}
