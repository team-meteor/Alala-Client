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
	
	private lazy var selectionViewController: UINavigationController = {
		
		var viewController = UINavigationController(rootViewController: SelectionViewController())
		
		// Add View Controller as Child View Controller
		self.add(asChildViewController: viewController)
		
		return viewController
	}()
	
	private lazy var rejectViewController: UINavigationController = {
		
		var viewController = UINavigationController(rootViewController: RejectViewController())
		
		// Add View Controller as Child View Controller
		self.add(asChildViewController: viewController)
		
		return viewController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupView()
	}
	
	private func setupView() {
//		self.checkPhotoLibraryAuthorization { authorized in
//			if authorized {
//				self.add(asChildViewController: self.selectionViewController)
//			} else {
//				self.add(asChildViewController: self.selectionViewController)
//			}
//		}
		
		if PHPhotoLibrary.authorizationStatus() != .authorized {
			PHPhotoLibrary.requestAuthorization( { status in
				if status == .authorized {
					//self.remove(asChildViewController: self.rejectViewController)
					self.add(asChildViewController: self.selectionViewController)
				} else {
					//self.remove(asChildViewController: self.selectionViewController)
					self.add(asChildViewController: self.rejectViewController)
				}
			} )
		} else {
			//self.remove(asChildViewController: self.rejectViewController)
			self.add(asChildViewController: self.selectionViewController)
		}
	}
	
//	func checkPhotoLibraryAuthorization(_ completionHandler: @escaping ((_ authorized: Bool) -> Void)) {
//		switch PHPhotoLibrary.authorizationStatus() {
//		case .authorized:
//			// The user has previously granted access to the photo library.
//			completionHandler(true)
//			
//		case .notDetermined:
//			// The user has not yet been presented with the option to grant photo library access so request access.
//			PHPhotoLibrary.requestAuthorization({ status in
//				completionHandler((status == .authorized))
//			})
//			
//		case .denied:
//			// The user has previously denied access.
//			completionHandler(false)
//			
//		case .restricted:
//			// The user doesn't have the authority to request access e.g. parental restriction.
//			completionHandler(false)
//		}
//	}
	
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
