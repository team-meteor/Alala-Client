//
//  PostCollectionTests.swift
//  Alala
//
//  Created by junwoo on 2017. 8. 11..
//  Copyright © 2017년 team-meteor. All rights reserved.
//

import XCTest
@testable import Alala
import ObjectMapper

class PostCollectionTests: XCTestCase {

  var collection: PostCollection!
  let bundle = Bundle(for: PostCollectionTests.self)

  override func setUp() {
    super.setUp()
    collection = PostCollection()

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

  func testCollectionHasExpectedCurrentPage() {
    XCTAssert(collection.getCurrentPage() == "3",
              "Collection didn't have expected currentPage")
  }

  func testCollectionIsNoPosts() {
    XCTAssertFalse(collection.isNoPost)

    collection.removeAllPosts()
    XCTAssertTrue(collection.isNoPost)
  }

  func testCanInsertPost() {
    // given
    if let path: URL = bundle.url(forResource: "post", withExtension: "json"),
      let data = try? Data(contentsOf: path, options: Data.ReadingOptions.alwaysMapped),
      let string = String(data: data, encoding: String.Encoding.utf8),
      let post = Mapper<Post>().map(JSONString: string) {
      // when
      collection.insertPost(post)

      // then
      XCTAssertTrue(collection.getPosts().contains(post))
    }
  }
}
