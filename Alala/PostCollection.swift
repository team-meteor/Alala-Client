//
//  PostCollection.swift
//  Alala
//
//  Created by hoemoon on 05/08/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import Foundation

class PostCollection {
  private var _posts: [Post] = []
  private var _nextPage: String = "1"
  private var _paging: Paging {
    get {
      if self._nextPage != "1" {
        return .next(self._nextPage)
      } else {
        return .refresh
      }
    }
  }
  internal var _feedNetworkManager = FeedService()

  var isNoPost: Bool {
    get {
      return self._posts.count <= 0 ? true : false
    }
  }

  convenience init() {
    self.init([])
  }

  init(_ posts: [Post]) {
    self._posts = posts
  }

  public func getPosts() -> [Post] {
    return self._posts
  }

  public subscript(index: Int) -> Post {
    return _posts[index]
  }

  public func loadFeedFromJSON(_ jsonFileName: String, in bundle: Bundle) {
    if let path = bundle.path(forResource: jsonFileName, ofType: "json") {
      if let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped),
        let string = String(data: data, encoding: .utf8),
        let feed = Feed(JSONString: string) {
        self._posts = feed._posts!
        self._nextPage = feed._nextPage!
      }
    } else {
      print("file not exists")
    }
  }

  public func loadFromCloud(completion: @escaping ((Bool) -> Void)) {
    _feedNetworkManager.feed(paging: self._paging) { [weak self] response in
      guard let strongSelf = self else { return }
      switch response.result {
      case .success(let feed):
        let newPosts = feed._posts ?? []
        switch strongSelf._paging {
        case .refresh:
          strongSelf._posts = newPosts
        case .next:
          strongSelf._posts.append(contentsOf: newPosts)
        }
        if let page = feed._nextPage {
          strongSelf._nextPage = page
        }
        completion(true)
      case .failure(let error):
        print(error)
        completion(false)
      }
    }
  }

  public func loadMineFromCloud(completion: @escaping ((Bool) -> Void)) {
    _feedNetworkManager.feed(isMine: true, paging: self._paging) { [weak self] response in
      guard let strongSelf = self else { return }
      switch response.result {
      case .success(let feed):
        let newPosts = feed._posts ?? []
        switch strongSelf._paging {
        case .refresh:
          strongSelf._posts = newPosts
        case .next:
          strongSelf._posts.append(contentsOf: newPosts)
        }
        if let page = feed._nextPage {
          strongSelf._nextPage = page
        }
        completion(true)
      case .failure(let error):
        print(error)
        completion(false)
      }
    }
  }

  public func count() -> Int {
    return self._posts.count
  }

  public func insertPost(_ post: Post) {
    self._posts.insert(post, at: 0)
  }

  public func refreshCollection() {
    self._nextPage = "1"
  }

  public func getCurrentPage() -> String {
    return self._nextPage
  }
}
