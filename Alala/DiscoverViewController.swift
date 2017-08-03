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
  fileprivate var filteredUsers = [User]()

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
    UserService.instance.getAllRegisterdUsers { users in
      self.allUsers = (users?.filter({$0?.email != AuthService.instance.currentUser?.email}))! as! [User]

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

    searchController.searchResultsUpdater = self as? UISearchResultsUpdating
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    tableView.tableHeaderView = searchController.searchBar
    tableView.tableFooterView = UIView(frame: CGRect.zero)

    searchController.searchBar.scopeButtonTitles = ["인기", "사람", "태그", "장소"]
    searchController.searchBar.delegate = self
    tableView.dataSource = self
    tableView.delegate = self

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

  func filterContentForSearchText(searchText: String, scope: String = "인기") {
    filteredUsers = allUsers.filter { user in
      let categoryMatch = (scope == "인기")
      return categoryMatch && (user.profileName?.lowercased().contains(searchText.lowercased()))!
    }
    tableView.reloadData()
  }

  func updateSearchResultForSearchController(searchController: UISearchController) {
    let searchBar = searchController.searchBar
    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
    filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
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
    if searchController.isActive && searchController.searchBar.text != "" {
      return filteredUsers.count
    }

    return self.allUsers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellReuseIdentifier) as! SearchTableViewCell

    cell.selectionStyle = .none
    if searchController.isActive && searchController.searchBar.text != "" {
      cell.userInfo = filteredUsers[indexPath.item]
    } else {
      cell.userInfo = self.allUsers[indexPath.item]
    }

    return cell
  }
}

extension DiscoverViewController: UITableViewDelegate {

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return CGFloat(SearchTableViewCell.cellHeight)
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let rowUser = self.allUsers[indexPath.row]
    let profileVC = PersonalViewController(user:rowUser)
    self.navigationController?.pushViewController(profileVC, animated: true)
  }
}

extension DiscoverViewController: UISearchResultsUpdating {
  func updateSearchResults(for searchController: UISearchController) {
    filterContentForSearchText(searchText: searchController.searchBar.text!)
  }
}
