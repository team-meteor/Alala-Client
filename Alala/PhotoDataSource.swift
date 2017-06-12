//
//  PhotoDataSource.swift
//  Alala
//
//  Created by junwoo on 2017. 6. 9..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import Foundation

class PhotoDataSource {
    
    var posts = [Post]()
    
    init() {
        posts = loadPhotosFromPlist()
    }
    
    func loadPhotosFromPlist() -> [Post] {
        if let path = Bundle.main.path(forResource: "NationalParks", ofType: "plist") {
            if let dictArray = NSArray(contentsOfFile: path) {
                var photos = [Post]()
                for item in dictArray {
                    if let dict = item as? NSDictionary {
                        let photoID = dict["photo"] as? String
                        let message = dict["description"] as? String
                        var post = Post(photoID: photoID, description: message)
                        photos.append(post)
                    }
                }
                return photos
            }
        }
        return []
    }
    
}
