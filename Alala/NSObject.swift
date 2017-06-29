//
//  NSObject.swift
//  Alala
//
//  Created by hoemoon on 29/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation
import IGListKit

extension NSObject: ListDiffable {

  public func diffIdentifier() -> NSObjectProtocol {
    return self
  }

  public func isEqual(toDiffableObject object: ListDiffable?) -> Bool {
    return isEqual(object)
  }

}
