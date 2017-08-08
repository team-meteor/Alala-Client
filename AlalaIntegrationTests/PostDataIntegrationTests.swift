//
//  PostDataIntegrationTests.swift
//  Alala
//
//  Created by hoemoon on 08/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import XCTest
@testable import Alala

class PostDataIntegrationTests: XCTestCase {

  override func setUp() {
    super.setUp()
  }

  override func tearDown() {
    super.tearDown()
  }

  func testPostWithMultipartStringArrayFails() {
    // given
    let mockPostNetworkService = MockPostNetworkService()
    PostDataManager.postNetworkManager = mockPostNetworkService
    let expecation = expectation(description: "Expected post with mutipartIDStringArray from cloud to fails")

    // when
    let testArray: [String] = ["1708085047", "1708085054", "1708085101"]
    PostDataManager.postWithMultiPartCloud(
      multipartIDArray: testArray,
      message: nil,
      progress: nil) { response in
        expecation.fulfill()
        if case .success(let post) = response.result {
          XCTAssertNotEqual(testArray, post.multipartIds)
        }
    }
    // then
    waitForExpectations(timeout: 0.1, handler: nil)
  }

  func testPostWithMultipartStringArraySucceeds() {
    // given
    let mockPostNetworkService = MockPostNetworkService()
    PostDataManager.postNetworkManager = mockPostNetworkService
    let expecation = expectation(description: "Expected post with mutipartIDStringArray from cloud to succeed")

    // when
    var originArray = mockPostNetworkService.somepost.multipartIds!
    let testArray = ["1708085047", "1708085054", "1708085101"]
    PostDataManager.postWithMultiPartCloud(
      multipartIDArray: testArray,
      message: nil,
      progress: nil) { response in
        expecation.fulfill()
        if case .success(let post) = response.result {
          originArray.append(contentsOf: testArray)
          XCTAssertEqual(originArray, post.multipartIds)
        }
    }
    // then
    waitForExpectations(timeout: 0.1, handler: nil)
  }
  
  func testPostLikeFails() {
    let mockPostNetworkService = MockPostNetworkService()
    PostDataManager.postNetworkManager = mockPostNetworkService
    let expecation = expectation(description: "like post fails")
  }
}
