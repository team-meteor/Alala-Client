//
//  FileManager.swift
//  Alala
//
//  Created by junwoo on 2017. 7. 19..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import Foundation

extension FileManager {
  func getOutputPath( _ name: String ) -> String {
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true )[ 0 ] as NSString
    let outputPath = "\(documentPath)/\(name).mov"
    return outputPath
  }
}
