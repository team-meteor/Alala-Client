//
//  AuthServiece.swift
//  Alala
//
//  Created by hoemoon on 12/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import AWSS3

let credentialProvider = AWSStaticCredentialsProvider(accessKey: Credentials.AccesskeyID, secretKey: Credentials.SecretAccesskey)
let configuration = AWSServiceConfiguration(region: AWSRegionType.APNortheast2, credentialsProvider: credentialProvider)

struct PhotoService {
	static func uploadPhoto(photoURL: URL) {
		AWSServiceManager.default().defaultServiceConfiguration = configuration
		let uploadRequest = AWSS3TransferManagerUploadRequest()!
		uploadRequest.body = photoURL
		uploadRequest.key = UUID().uuidString
		uploadRequest.bucket = "alala-source-bucket"
		uploadRequest.contentType = "image/jpeg"
		uploadRequest.acl = .publicRead
		
		let transeferManager = AWSS3TransferManager.default()
		transeferManager.upload(uploadRequest).continueWith { (task: AWSTask<AnyObject>) -> Any? in
			if let error = task.error {
				print("Upload faild with error: \(error.localizedDescription)")
			}
			if task.result != nil {
				let url = AWSS3.default().configuration.endpoint.url
				let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
				print(publicURL!)
			}
			return nil
		}
	}
}
