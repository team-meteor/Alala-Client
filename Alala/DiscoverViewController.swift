import UIKit

class DiscoverViewController: UIViewController {

  fileprivate let searchBar = UISearchBar().then {
    $0.showsCancelButton = true
    $0.placeholder = "검색"
    $0.barTintColor = .white
    $0.layer.borderColor = UIColor.white.cgColor
    $0.layer.borderWidth = 1.0
  }

  fileprivate let customScopeBar = UISegmentedControl(items: ["인기", "사람", "태그", "장소"]).then {
    $0.selectedSegmentIndex = 0
    $0.tintColor = UIColor(red: 201, green: 201, blue: 206)
    $0.layer.borderColor = UIColor(red: 201, green: 201, blue: 206).cgColor
    $0.layer.borderWidth = 1.0
  }

  fileprivate let baseScrollView = UIScrollView().then {
    $0.showsHorizontalScrollIndicator = false
    $0.showsVerticalScrollIndicator = false
    $0.isPagingEnabled = true
    $0.backgroundColor = .white
    $0.bounces = true
  }

  fileprivate let sectionA = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
  }
  fileprivate let sectionB = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
  }
  fileprivate let sectionC = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
  }
  fileprivate let sectionD = UITableView().then {
    $0.isScrollEnabled = true
    $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
  }
  fileprivate let selectedBar = UIView().then {
    $0.backgroundColor = .black
  }

  fileprivate let searchPersonVC = SearchPersonViewController()
  fileprivate let userDataManager = UserDataManager.shared
  fileprivate var allUsers = [User]()
  //fileprivate var filteredUsers = [User]()

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

    self.navigationController?.isNavigationBarHidden = true

    userDataManager.getMeWithCloud { _ in}
    userDataManager.getAllUsersWithCloud { users in
      self.allUsers = (users.filter({$0.email != self.userDataManager.currentUser?.email}))
      self.sectionA.reloadData()
      self.sectionB.reloadData()
      self.sectionC.reloadData()
      self.sectionD.reloadData()
    }

    setupUI()

  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.isNavigationBarHidden = true
  }

  func setupUI() {

    setSearchBarUI()
    setCustomScopeBarUI()
    setBaseScrollViewUI()
    setTableViewUI()
    displayContentController(content: searchPersonVC)
    customizingSearchBar()
    customizingScopeBar()
  }

  func setSearchBarUI() {
    self.view.addSubview(self.searchBar)

    self.searchBar.snp.makeConstraints { make in
      make.top.equalTo(UIApplication.shared.statusBarFrame.maxY)
      make.left.right.equalTo(self.view)
      make.height.equalTo(setValue("searchBarHeight"))
    }
  }

  func setCustomScopeBarUI() {

    self.view.addSubview(self.customScopeBar)
    self.view.addSubview(self.selectedBar)

    self.customScopeBar.snp.makeConstraints { make in
      make.top.equalTo(searchBar.snp.bottom).offset(10)
      make.left.equalTo(self.view).offset(-1)
      make.right.equalTo(self.view).offset(1)
      make.height.equalTo(setValue("customScopeBarHeight"))
    }

    self.selectedBar.snp.makeConstraints { make in
      make.bottom.equalTo(customScopeBar.snp.bottom)
      make.height.equalTo(1)
      make.width.equalTo(setValue("screenWidth")/4)
    }

    customScopeBar.addTarget(self, action: #selector(scrollViewAction), for: .valueChanged)
  }

  func setBaseScrollViewUI() {
    self.baseScrollView.contentSize = CGSize(width: setValue("scollViewWidth") * 4, height: setValue("scrollViewHeight"))
    self.view.addSubview(self.baseScrollView)

    baseScrollView.delegate = self

    self.baseScrollView.snp.makeConstraints { make in
    make.left.right.equalTo(self.view)
    make.top.equalTo(customScopeBar.snp.bottom).offset(1)
    make.bottom.equalTo(view).offset(-25)
    }
  }

  func setTableViewUI() {

    self.baseScrollView.addSubview(self.sectionA)
    self.baseScrollView.addSubview(self.sectionB)
    self.baseScrollView.addSubview(self.sectionC)
    self.baseScrollView.addSubview(self.sectionD)

    self.sectionA.snp.makeConstraints { make in
      make.top.bottom.left.equalTo(self.baseScrollView)
      make.width.equalTo(setValue("scollViewWidth"))
      make.height.equalTo(setValue("scrollViewHeight"))
    }

    self.sectionB.snp.makeConstraints { make in
      make.left.equalTo(self.sectionA.snp.right)
      make.top.bottom.equalTo(self.baseScrollView)
      make.width.equalTo(setValue("scollViewWidth"))
      make.height.equalTo(setValue("scrollViewHeight"))
    }

    self.sectionC.snp.makeConstraints { make in
      make.left.equalTo(self.sectionB.snp.right)
      make.top.bottom.equalTo(self.baseScrollView)
      make.width.equalTo(setValue("scollViewWidth"))
      make.height.equalTo(setValue("scrollViewHeight"))
    }

    self.sectionD.snp.makeConstraints { make in
      make.left.equalTo(self.sectionC.snp.right)
      make.top.bottom.right.equalTo(self.baseScrollView)
      make.width.equalTo(setValue("scollViewWidth"))
      make.height.equalTo(setValue("scrollViewHeight"))
    }

    sectionA.tableFooterView = UIView(frame: CGRect.zero)
    sectionB.tableFooterView = UIView(frame: CGRect.zero)
    sectionC.tableFooterView = UIView(frame: CGRect.zero)
    sectionD.tableFooterView = UIView(frame: CGRect.zero)

    searchBar.delegate = self

    sectionA.dataSource = self
    sectionA.delegate = self
    sectionB.dataSource = self
    sectionB.delegate = self
    sectionC.dataSource = self
    sectionC.delegate = self
    sectionD.dataSource = self
    sectionD.delegate = self
  }

  func displayContentController(content: UIViewController) {
    self.addChildViewController(content)
    self.view.addSubview(content.view)
    content.view.snp.makeConstraints { make in
      make.bottom.left.right.equalTo(self.view)
      make.top.equalTo(searchBar.snp.bottom)
    }
    content.didMove(toParentViewController: self)
  }

  func hideContentController(content: UIViewController) {
    content.willMove(toParentViewController: nil)
    content.view.removeFromSuperview()
    content.removeFromParentViewController()
  }

  func customizingSearchBar() {
    let textField = searchBar.value(forKey: "searchField") as! UITextField
    textField.backgroundColor = UIColor(red: 201, green: 201, blue: 206)
    searchBar.setValue("취소", forKey:"_cancelButtonText")
  }

  func customizingScopeBar() {
    customScopeBar.removeBorders()
  }

  func setValue(_ name: String) -> CGFloat {
    let screenWidth = self.view.frame.width
    let screenHeight = self.view.frame.height

    let searchBarHeight: CGFloat = 30
    let customScopeBarHeight: CGFloat = 30
    let tabBarItemHeight: CGFloat = 25

    let scollViewWidth = screenWidth
    let scrollViewHeight = screenHeight - UIApplication.shared.statusBarFrame.maxY - searchBarHeight - customScopeBarHeight - tabBarItemHeight

    switch name {
    case "screenWidth":
      return screenWidth
    case "screenHeight":
      return screenHeight
    case "customScopeBarHeight":
      return customScopeBarHeight
    case "searchBarHeight":
      return searchBarHeight
    case "tabBarItemHeight":
      return tabBarItemHeight
    case "scrollViewHeight":
      return scrollViewHeight
    case "scollViewWidth":
      return scollViewWidth
    default:
      return CGFloat(0)
    }
  }

  func scrollViewAction() {
    let currentIndex = customScopeBar.selectedSegmentIndex

    if currentIndex == 0 {
      self.baseScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    } else if currentIndex == 1 {
      self.baseScrollView.setContentOffset(CGPoint(x: setValue("screenWidth") * 1, y: 0), animated: true)
    } else if currentIndex == 2 {
      self.baseScrollView.setContentOffset(CGPoint(x: setValue("screenWidth") * 2, y: 0), animated: true)
    } else if currentIndex == 3 {
      self.baseScrollView.setContentOffset(CGPoint(x: setValue("screenWidth") * 3, y: 0), animated: true)
    }
  }
}

extension DiscoverViewController: UISearchBarDelegate {

  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = true

    hideContentController(content: searchPersonVC)
  }

  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.showsCancelButton = false
    searchBar.endEditing(true)

    displayContentController(content: searchPersonVC)
  }

}

extension UISegmentedControl {
  func removeBorders() {
    setBackgroundImage(imageWithColor(color: .clear), for: .normal, barMetrics: .default)
    setBackgroundImage(imageWithColor(color: .clear), for: .selected, barMetrics: .default)

    setDividerImage(imageWithColor(color: UIColor.clear), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
  }

  private func imageWithColor(color: UIColor) -> UIImage {
    let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return image!
  }
}

extension DiscoverViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//    if searchController.isActive && searchController.searchBar.text != "" {
//      return filteredUsers.count
//    }

    return self.allUsers.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//    if searchController.isActive && searchController.searchBar.text != "" {
//      cell.userInfo = filteredUsers[indexPath.item]
//    } else {
//      cell.userInfo = self.allUsers[indexPath.item]
//    }

    let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellReuseIdentifier) as! SearchTableViewCell
    cell.selectionStyle = .none
    cell.userInfo = self.allUsers[indexPath.item]

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

extension DiscoverViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if scrollView == baseScrollView {
      let currentOffset = baseScrollView.contentOffset.x

      selectedBar.frame.origin.x = currentOffset / 4
    }
  }
}

//
//  func setupUI() {
//
//    self.view.addSubview(self.tableView)
//
//    self.tableView.snp.makeConstraints { make in
//      make.bottom.left.right.equalTo(self.view)
//      make.top.equalTo(UIApplication.shared.statusBarFrame.maxY)
//    }
//
//    searchController.searchResultsUpdater = self as? UISearchResultsUpdating
//    searchController.dimsBackgroundDuringPresentation = false
//    definesPresentationContext = true
//    tableView.tableHeaderView = searchController.searchBar
//    tableView.tableFooterView = UIView(frame: CGRect.zero)
//
//
//    tableView.dataSource = self
//    tableView.delegate = self
//
//    customScopeBarUI()
//    displayContentController(content: searchPersonVC)
//    customizingSearchBar()
//  }
//
//  func customScopeBarUI() {
//    self.customScopeBar.snp.makeConstraints { make in
//      make.top.equalTo(self.searchController.searchBar.snp.bottom)
//      make.left.right.equalTo(self.view)
//      make.height.equalTo(60)
//    }
//
//    self.view.addSubview(customScopeBar)
//  }
//
//  func displayContentController(content: UIViewController) {
//
//    guard let header = self.tableView.tableHeaderView else { return }
//    let status = UIApplication.shared.statusBarFrame.height
//
//    let searchBarHeight = header.frame.height + status
//
//    self.addChildViewController(content)
//    self.view.addSubview(content.view)
//
//    content.view.snp.makeConstraints { make in
//      make.bottom.left.right.equalTo(self.view)
//      make.top.equalTo(self.view).offset(searchBarHeight)
//    }
//
//    content.didMove(toParentViewController: self)
//
//  }
//
//  func hideContentController(content: UIViewController) {
//    content.willMove(toParentViewController: nil)
//    content.view.removeFromSuperview()
//    content.removeFromParentViewController()
//  }
//
//  func customizingSearchBar() {
//
//    let textField = searchController.searchBar.value(forKey: "searchField") as! UITextField
//    textField.backgroundColor = UIColor(red: 201, green: 201, blue: 206)
//
//    searchController.searchBar.setValue("취소", forKey:"_cancelButtonText")
//
//    searchController.searchBar.placeholder = "검색"
//
//    searchController.searchBar.barTintColor = .white
//
//    searchController.searchBar.layer.borderColor = UIColor.white.cgColor
//    searchController.searchBar.layer.borderWidth = 1.0
//  }
//
//  func filterContentForSearchText(searchText: String, scope: String = "인기") {
//    filteredUsers = allUsers.filter { user in
//      let categoryMatch = (scope == "인기")
//      return categoryMatch && (user.profileName?.lowercased().contains(searchText.lowercased()))!
//    }
//    tableView.reloadData()
//  }
//
//  func updateSearchResultForSearchController(searchController: UISearchController) {
//    let searchBar = searchController.searchBar
//    let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//    filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
//  }
//}
//
//
//}
//
//extension DiscoverViewController: UISearchResultsUpdating {
//  func updateSearchResults(for searchController: UISearchController) {
//    filterContentForSearchText(searchText: searchController.searchBar.text!)
//  }
//}
