//
//  EditProfileViewController.swift
//  Alala
//
//  Created by Ellie Kwon on 2017. 6. 28..
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit

/**
 * # 내 프로필 편집 화면
 *
 * **[PATH]** 내 프로필 화면 > '프로필 수정' 버튼 탭
 */
class EditProfileViewController: UIViewController {

  let me = AuthService.instance.currentUser

  let contentView = UIView()

  let currentProfileImageView = CircleImageView().then {
    $0.layer.borderWidth = 1
    $0.layer.masksToBounds = false
    $0.layer.borderColor = UIColor.lightGray.cgColor
    $0.clipsToBounds = true
    $0.isUserInteractionEnabled = true
  }

  let changePhotoButton = UIButton().then {
    $0.setTitle("Change Profile Photo", for: .normal)
    $0.addTarget(self, action: #selector(changePhotoButtonTap), for: .touchUpInside)
    $0.setTitleColor(UIColor.blue, for: .normal)
  }
  let contentTableView = UITableView()
  let cellReuseIdentifier = "cell"

  var allProfileItemArray = [[ProfileItem]]()
  var publicItemArray = [ProfileItem]()
  var privateItemArray = [ProfileItem]()

  override func viewDidLoad() {
    super.viewDidLoad()

    self.edgesForExtendedLayout = []

    setupNavigation()

    setupProfileItem()

    setupUI()

    setupMyUserData()
  }

  /**
   * Setup NavigationItem
   */
  func setupNavigation() {
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: UIBarButtonItemStyle.plain,
                                                            target: self,
                                                            action: #selector(backNaviButtonTap))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done",
                                                             style: UIBarButtonItemStyle.done,
                                                             target: self,
                                                             action: #selector(doneNaviButtonTap))
    self.title = "EditProfile"
  }

  /**
   * 각 row에 출력될 프로필 아이템 데이터 설정
   */
  func setupProfileItem() {
    publicItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "Name"))
    publicItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "Username"))
    publicItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "Website"))
    publicItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "Bio"))

    privateItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "Email"))
    privateItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "Phone"))
    privateItemArray.append(ProfileItem(iconImageName: "personal", placeHolder: "gender"))

    allProfileItemArray = [publicItemArray, privateItemArray]
  }

  func setupUI() {
    self.view.backgroundColor = UIColor(rgb: 0xeeeeee)
    self.view.addSubview(contentTableView)
    contentTableView.snp.makeConstraints { (make) in
      //make.top.equalTo(changePhotoButton.snp.bottom).offset(5)
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.bottom.equalTo(self.view)
    }
    contentTableView.dataSource = self
    contentTableView.delegate = self
    contentTableView.register(EditProfileTableViewCell.self, forCellReuseIdentifier: cellReuseIdentifier)
    contentTableView.tableFooterView = UIView()

    let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 130))
    tableHeaderView.backgroundColor = UIColor(rgb: 0xeeeeee)
    tableHeaderView.addSubview(currentProfileImageView)
    tableHeaderView.addSubview(changePhotoButton)
    currentProfileImageView.snp.makeConstraints { (make) in
      make.top.equalTo(tableHeaderView).offset(20)
      make.centerX.equalTo(tableHeaderView)
      make.width.equalTo(70)
      make.height.equalTo(70)
    }
    currentProfileImageView.addGestureRecognizer(UITapGestureRecognizer(
      target: self,
      action: #selector(self.changePhotoButtonTap))
    )

    changePhotoButton.snp.makeConstraints { (make) in
      make.top.equalTo(currentProfileImageView.snp.bottom).offset(5)
      make.left.equalTo(tableHeaderView)
      make.right.equalTo(tableHeaderView)
      make.height.equalTo(20)
    }
    contentTableView.tableHeaderView = tableHeaderView
  }

  func setupMyUserData() {
    currentProfileImageView.setImage(with: me?.profilePhotoId, size: .small)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  func doneNaviButtonTap() {

  }

  func changePhotoButtonTap() {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    self.present(pickerController, animated: true, completion: nil)
  }

}

extension EditProfileViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
    self.currentProfileImageView.image = selectedImage
    self.dismiss(animated: true, completion: nil)
  }
}
extension EditProfileViewController: UINavigationControllerDelegate {
}

extension EditProfileViewController: UITableViewDataSource {
  // MARK: Tableview DataSource
  func numberOfSections(in tableView: UITableView) -> Int {
    return allProfileItemArray.count
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let array = allProfileItemArray[section]
    return (array as AnyObject).count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // create a new cell if needed or reuse an old one
    let cell: EditProfileTableViewCell = contentTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! EditProfileTableViewCell
    let array = allProfileItemArray[indexPath.section] as Array
    let profileItem = array[indexPath.row] as ProfileItem
    cell.textView.text = profileItem.placeHolder

    // 우측에 버튼을 출력하는 Cell은 constant값을 주어 레이아웃 변경 가능
    /*
    cell.rightButtonWidthConstraint?.constant = 0
    cell.needsUpdateConstraints()
    */
    return cell
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return section==0 ? 0.5 : 40
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0.5))
      view.backgroundColor = UIColor(rgb: 0xeeeeee)
      return view
    } else {
      let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
      let label = UILabel()
      label.font = UIFont.systemFont(ofSize: 10)
      label.text = "PRIVATE INFORMATION"
      view.addSubview(label)
      view.backgroundColor = UIColor(rgb: 0xeeeeee)
      label.snp.makeConstraints { (make) in
        make.leftMargin.equalTo(view).offset(10)
        make.bottomMargin.equalTo(view)
        make.rightMargin.equalTo(view)
        make.height.equalTo(18)
      }
      return view
    }
  }

  func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
      if(isLastRowOfTableView(tableView, indexPath: indexPath)) {
        cell.separatorInset = UIEdgeInsets.zero
      } else {
        cell.separatorInset = EditProfileTableViewCell.cellSeparatorInsets
      }
    }
  }

  func isLastRowOfTableView(_ tableView: UITableView, indexPath: IndexPath) -> Bool {
    let lastRowIndex = tableView.numberOfRows(inSection: tableView.numberOfSections-1)
    return  (indexPath.row == lastRowIndex - 1)
  }
}

extension EditProfileViewController: UITableViewDelegate {
  // method to run when table view cell is tapped
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("You tapped cell number \(indexPath.row).")
  }

  // MARK: User Action
  func backNaviButtonTap() {
    if self.navigationController?.viewControllers.first == self {
      self.dismiss(animated: true)
    } else {
      self.navigationController?.popViewController(animated: true)
    }

  }
}

struct ProfileItem {
  var iconImageName: String
  var placeHolder: String

  init(iconImageName: String, placeHolder: String) {
    self.placeHolder = placeHolder
    self.iconImageName = iconImageName
  }
}
