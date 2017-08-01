//
//  DiscoverViewController.swift
//  Alala
//
//  Created by hoemoon on 05/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

class DiscoverViewController: UIViewController {

  fileprivate let tableView = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
  }

  fileprivate let searchController = UISearchController(searchResultsController: nil)
  fileprivate let searchPersonVC = SearchPersonViewController()
  fileprivate var allUsers = [User]()

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    self.tabBarItem.image = UIImage(named: "discover")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.selectedImage = UIImage(named: "discover-selected")?.resizeImage(scaledTolength: 25)
    self.tabBarItem.imageInsets.top = 5
    self.tabBarItem.imageInsets.bottom = -5
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    AuthService.instance.me { _ in}
    UserService.instance.getAllRegisterdUsers { user in
      self.allUsers = user?.filter({$0?.email != AuthService.instance.currentUser?.email}) as! [User]
      self.tableView.reloadData()
    }

    setupUI()

  }

  func setupUI() {

    self.view.addSubview(self.tableView)

    self.tableView.snp.makeConstraints { make in
      make.bottom.left.right.equalTo(self.view)
      make.top.equalTo(UIApplication.shared.statusBarFrame.maxY)
    }

    self.tableView.rowHeight = 60

    searchController.searchResultsUpdater = self as? UISearchResultsUpdating
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar

    searchController.searchBar.delegate = self
    tableView.dataSource = self

    displayContentController(content: searchPersonVC)
    customizingSearchBar()

  }

  func displayContentController(content: UIViewController) {

    guard let header = self.tableView.tableHeaderView else { return }
    let status = UIApplication.shared.statusBarFrame.height

    let searchBarHeight = header.frame.height + status

    self.addChildViewController(content)
    self.view.addSubview(content.view)

    content.view.snp.makeConstraints { make in
      make.bottom.left.right.equalTo(self.view)
      make.top.equalTo(self.view).offset(searchBarHeight)
    }

    content.didMove(toParentViewController: self)

  }

  func hideContentController(content: UIViewController) {
    content.willMove(toParentViewController: nil)
    content.view.removeFromSuperview()
    content.removeFromParentViewController()
  }

  func customizingSearchBar() {

    let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
    textField.backgroundColor = UIColor(red: 201, green: 201, blue: 206)

    searchController.searchBar.setValue("취소", forKey:"_cancelButtonText")

    searchController.searchBar.placeholder = "검색"

    searchController.searchBar.barTintColor = .white

    searchController.searchBar.layer.borderColor = UIColor.white.cgColor
    searchController.searchBar.layer.borderWidth = 1.0
  }
}

extension DiscoverViewController: UISearchBarDelegate {

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchController.searchBar.showsCancelButton = true

    hideContentController(content: searchPersonVC)
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchController.searchBar.showsCancelButton = false
    searchController.searchBar.endEditing(true)

    displayContentController(content: searchPersonVC)
  }

}

extension DiscoverViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.allUsers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellReuseIdentifier) as! SearchTableViewCell
    cell.selectionStyle = .none
    cell.userInfo = self.allUsers[indexPath.item]
    return cell
  }
}
