//
//  OptionsViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 28..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * # 옵션 목록 화면
 *
 * **[PATH]** 내 프로필 화면 > '설정' 아이콘 탭
 */
class OptionsViewController: UIViewController {

  let contentTableView = UITableView()
  let userDataManager = UserDataManager.shared

  var allOptionItemArray: [[String:[OptionItem]]] = []

  override func viewDidLoad() {
    super.viewDidLoad()

    self.navigationItem.titleView = UILabel().then {
      $0.font = UIFont(.navigation)
      $0.text = "Options"
      $0.sizeToFit()
    }

    setupUI()

    setupOptionItemData()
  }

  func setupUI() {
    self.view.backgroundColor = UIColor(rgb: 0xefefef)
    self.view.addSubview(contentTableView)
    contentTableView.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }
    contentTableView.dataSource = self
    contentTableView.delegate = self
    contentTableView.tableFooterView = UIView()
    contentTableView.backgroundColor = UIColor(rgb: 0xefefef)
    contentTableView.separatorColor = UIColor.lightGray
    contentTableView.separatorStyle = .singleLine
    contentTableView.layoutMargins = UIEdgeInsets.zero

    //self.edgesForExtendedLayout = []
    //self.automaticallyAdjustsScrollViewInsets = false
  }

  /**
   * 각 row에 출력될 옵션 항목 데이터 설정
   */
  func setupOptionItemData() {
    allOptionItemArray = [
      ["계정": [OptionItem(iconImageName: "", title: "프로필 편집", rightButton: .arrow, funcName: "editProfileMenuTap"),
               OptionItem(iconImageName: "", title: "비밀번호 변경", rightButton: .arrow, funcName: "tempAlert"),
               OptionItem(iconImageName: "", title: "회원님이 좋아한 게시물", rightButton: .arrow, funcName: "tempAlert")]],
      ["정보": [OptionItem(iconImageName: "", title: "오픈 소스 라이브러리", rightButton: .none, funcName: "tempAlert")]],
      ["": [OptionItem(iconImageName: "", title: "로그아웃", rightButton: .none, funcName: "logoutButtonTap")]]
    ]
  }

  func tempAlert() {
    let alert = UIAlertController(title: "[ NOTICE ]", message: "추후 개발 예정 기능입니다.", preferredStyle: UIAlertControllerStyle.alert)
    alert.addAction(UIAlertAction(title: "Done", style: UIAlertActionStyle.default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }

  func editProfileMenuTap() {
    let editProfileVC = EditProfileViewController()
    self.navigationController?.pushViewController(editProfileVC, animated: true)
  }

  func logoutButtonTap() {
    userDataManager.logoutWithCloud { (success) in
      if success {
        NotificationCenter.default.post(name: .presentLogin, object: nil, userInfo: nil)
      } else {

      }
    }
  }
}

extension OptionsViewController: UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    return allOptionItemArray.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let dic: [String:[OptionItem]] = allOptionItemArray[section]
    let arr: [OptionItem] = dic.values.first!
    return arr.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // create a new cell if needed or reuse an old one

    let dic: [String:[OptionItem]] = allOptionItemArray[indexPath.section]
    let arr: [OptionItem] = dic.values.first!
    let data: OptionItem = arr[indexPath.row]

    let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    cell.textLabel?.text = data.title

    return cell
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let view = UIBorderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 50))
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 12)
    label.textColor = UIColor(rgb: 0x999999)
    view.addSubview(label)
    view.topBorderLine.isHidden = section == 0 ? true : false
    view.bottomBorderLine.isHidden = false
    label.snp.makeConstraints { (make) in
      make.leftMargin.equalTo(view).offset(20)
      make.bottom.equalTo(view).offset(-5)
      make.rightMargin.equalTo(view)
      make.height.equalTo(18)
    }

    let dic: [String:[OptionItem]] = allOptionItemArray[section]
    label.text = dic.keys.first

    return view
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
      if(isLastRowOfTableView(tableView, indexPath: indexPath)) {
        cell.separatorInset = UIEdgeInsets.zero
      } else {
        cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
      }
    }

    if cell.responds(to: #selector(setter: UITableViewCell.layoutMargins)) {
      cell.layoutMargins = UIEdgeInsets.zero
    }

    if cell.responds(to: #selector(setter: UITableViewCell.preservesSuperviewLayoutMargins)) {
      cell.preservesSuperviewLayoutMargins = false
    }
  }

  func isLastRowOfTableView(_ tableView: UITableView, indexPath: IndexPath) -> Bool {
    let lastRowIndex = tableView.numberOfRows(inSection: indexPath.section)
    return  (indexPath.row == lastRowIndex - 1)
  }
}

extension OptionsViewController: UITableViewDelegate {
  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let dic: [String:[OptionItem]] = allOptionItemArray[indexPath.section]
    let arr: [OptionItem] = dic.values.first!
    let data: OptionItem = arr[indexPath.row]

    performSelector(onMainThread: Selector(data.funcName), with: self, waitUntilDone: true)

    tableView.deselectRow(at: indexPath, animated: true)
  }
}

struct OptionItem {
  enum RightButtonType {
    case none
    case arrow
    case switching
  }
  var iconImageName: String
  var title: String
  var rightButton: RightButtonType
  var funcName: String

  init(iconImageName: String, title: String, rightButton: RightButtonType, funcName: String) {
    self.title = title
    self.iconImageName = iconImageName
    self.rightButton = rightButton
    self.funcName = funcName
  }
}
