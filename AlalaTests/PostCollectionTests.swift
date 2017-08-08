//
//  PostCollectionTests.swift
//  Alala
//
//  Created by junwoo on 2017. 8. 8..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import XCTest
@testable import Alala

class PostCollectionTests: XCTestCase {

  var collection: PostCollection!

  override func setUp() {
    super.setUp()

    collection = PostCollection()

    let bundle = Bundle(for: PostCollectionTests.self)
    collection.loadFeedFromJSON("feed", in: bundle)
  }

  override func tearDown() {

    collection = nil
    super.tearDown()
  }

  func testCollectionHasExpectedItemsCount() {
    XCTAssert(collection.count() == 10,
              "Collection didn't have expected number of items")
  }

  func testCollectionGetExpectedCurrentPage() {
    XCTAssert(collection.getCurrentPage() == "3", "Collection didn't have expected current page")
  }

}
