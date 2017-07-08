//
//  ContainerViewController.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 18..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import UIKit
import Photos

class LibraryViewController: UIViewController {
  private var permissionGranted = false
  private let sessionQueue = DispatchQueue(label: "library queue")

	private lazy var selectionViewController: UINavigationController = {
		var viewController = UINavigationController(rootViewController: SelectionViewController())
		//self.add(asChildViewController: viewController)
		return viewController
	}()

	private lazy var rejectViewController: UINavigationController = {
		var viewController = UINavigationController(rootViewController: RejectViewController())
		//self.add(asChildViewController: viewController)
		return viewController
	}()

  init() {
    super.init(nibName: nil, bundle: nil)
    checkPermission()
    sessionQueue.async { [unowned self] in
      DispatchQueue.main.async {
        self.add(asChildViewController: self.selectionViewController)
        //self.remove(asChildViewController: self.rejectViewController)
      }

    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
    self.remove(asChildViewController: selectionViewController)
    self.remove(asChildViewController: rejectViewController)
    print("library deinit")
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

	override func viewDidLoad() {
		super.viewDidLoad()
	}

  private func checkPermission() {
    switch PHPhotoLibrary.authorizationStatus() {
    case .authorized:
      permissionGranted = true
    case .notDetermined:
      requestPermission()
    default:
      permissionGranted = false
      DispatchQueue.main.async {
        self.add(asChildViewController: self.rejectViewController)
        //self.remove(asChildViewController: self.selectionViewController)
      }

    }
  }

  private func requestPermission() {
    sessionQueue.suspend()
    PHPhotoLibrary.requestAuthorization({ status in
      if status == .authorized {
        self.permissionGranted = true
        self.sessionQueue.resume()
      } else {
        DispatchQueue.main.async {
          self.add(asChildViewController: self.rejectViewController)
          //self.remove(asChildViewController: self.selectionViewController)
        }

      }
    })
  }

	private func add(asChildViewController viewController: UIViewController) {
		// Add Child View Controller

		addChildViewController(viewController)

		// Add Child View as Subview
		view.addSubview(viewController.view)

		// Configure Child View
		viewController.view.frame = view.bounds
		viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

		// Notify Child View Controller
		viewController.didMove(toParentViewController: self)
	}

	private func remove(asChildViewController viewController: UIViewController) {
		// Notify Child View Controller
		viewController.willMove(toParentViewController: nil)

		// Remove Child View From Superview
		viewController.view.removeFromSuperview()

		// Notify Child View Controller
		viewController.removeFromParentViewController()
	}

}
