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
  var tempMe: User?

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

  let pickerDataSource = ["입력되지 않음", "남성", "여성"]
  let genderPicker = UIPickerView()

  var allProfileItemArray: [[String:[ProfileItem]]] = []

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
   * 각 row에 출력될 프로필 아이템 설정
   */
  func setupProfileItem() {
    allProfileItemArray = [
      ["": [ProfileItem(key: "displayName", iconImageName: "nametag", placeHolder: "Name"),
            ProfileItem(key: "profileName", iconImageName: "personal", placeHolder: "Username"),
            ProfileItem(key: "website", iconImageName: "website", placeHolder: "Website"),
            ProfileItem(key: "bio", iconImageName: "information", placeHolder: "Bio")]],
      ["PRIVATE INFORMATION":
           [ProfileItem(key: "email", iconImageName: "email", placeHolder: "Email"),
            ProfileItem(key: "Phone", iconImageName: "phone", placeHolder: "Phone"),
            ProfileItem(key: "gender", iconImageName: "gender", placeHolder: "Gender")]]
    ]
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
    contentTableView.register(EditProfileTableViewCell.self, forCellReuseIdentifier: EditProfileTableViewCell.textFieldCell)
    contentTableView.register(EditProfileTableViewCell.self, forCellReuseIdentifier: EditProfileTableViewCell.textViewCell)
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

    genderPicker.dataSource = self
  }

  func setupMyUserData() {
    let encodedData = NSKeyedArchiver.archivedData(withRootObject: me!)
    tempMe = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? User

    currentProfileImageView.setImage(with: me?.profilePhotoId, size: .small)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.isNavigationBarHidden = false
  }

  // MARK: User Action
  func backNaviButtonTap() {
    if self.navigationController?.viewControllers.first == self {
      self.dismiss(animated: true)
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }

  /**
   * 수정 완료 버튼 선택 시 프로필 정보 업데이트
   */
  func doneNaviButtonTap() {

    updateCurrentInfoToTempMe()

    if User.isEqual(l:me!, r:tempMe!) {
      // 변경사항 없음
      self.backNaviButtonTap()
    } else {
      // 변경사항 존재
      if self.tempMe?.profilePhotoId?.characters.count == 0 {
        MultipartService.uploadMultipart(multiPartData: currentProfileImageView.image!, progressCompletion: { _ in
        }) { (imageId) in
          self.tempMe?.profilePhotoId = imageId
          self.requestProfileUpdate()
        }
      } else {
        requestProfileUpdate()
      }

    }
  }

  func requestProfileUpdate() {
    AuthService.instance.updateProfile(userInfo: self.tempMe!, completion: { (success) in
      if success {
        AuthService.instance.me(completion: { (user) in
          if user != nil {
            DispatchQueue.main.async {
              NotificationCenter.default.post(
                name: .profileUpdated,
                object: self,
                userInfo: ["user": user!]
              )
              self.backNaviButtonTap()
            }
          }
        })
      } else {
        print("failed update profile")
      }
    })
  }
  /**
   * 프로필 사진 ImageView Touch 혹은 프로필 사진 변경 버튼 선택 시
   */
  func changePhotoButtonTap() {
    let pickerController = UIImagePickerController()
    pickerController.delegate = self
    self.present(pickerController, animated: true, completion: nil)
  }

  func updateCurrentInfoToTempMe() {
    for section in 0..<contentTableView.numberOfSections {
      let dic: [String:[ProfileItem]] = allProfileItemArray[section]
      let arr: [ProfileItem] = dic.values.first!
      for row in 0..<contentTableView.numberOfRows(inSection: section) {
        let profileItem: ProfileItem = arr[row]
        let cell = contentTableView.cellForRow(at: IndexPath(row: row, section: section)) as! EditProfileTableViewCell
        if profileItem.key != "gender" {
          tempMe?.setValue(cell.getText(), forKey: profileItem.key)
        }

      }
    }
    //print(tempMe?.description!)
  }
}

extension EditProfileViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
    self.currentProfileImageView.image = selectedImage
    self.tempMe?.profilePhotoId = ""
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
    let dic: [String:[ProfileItem]] = allProfileItemArray[section]
    let arr: [ProfileItem] = dic.values.first!
    return arr.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    // create a new cell if needed or reuse an old one
    let dic: [String:[ProfileItem]] = allProfileItemArray[indexPath.section]
    let arr: [ProfileItem] = dic.values.first!
    let profileItem: ProfileItem = arr[indexPath.row]

    let cellReuseIdentifier: String
    if profileItem.key=="bio" {
      cellReuseIdentifier = EditProfileTableViewCell.textViewCell
    } else {
      cellReuseIdentifier = EditProfileTableViewCell.textFieldCell
    }

    let cell: EditProfileTableViewCell = contentTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! EditProfileTableViewCell

    if profileItem.key=="gender" {
      let gender = tempMe?.value(forKey: profileItem.key as String) as? String
      if gender?.characters.count == 0 {
        cell.setText(text: "입력되지 않음")
      } else {
        cell.setText(text: gender=="M" ? "남성" : "여성")
      }
      cell.isEnable = false
    } else {
      let text: String? = tempMe?.value(forKey: profileItem.key) as? String
      cell.setText(text: text)
    }

    cell.iconImageView.image = UIImage(named: profileItem.iconImageName)?.resizeImage(scaledTolength: 15)
    cell.setPlaceholder(text: profileItem.placeHolder)

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
      label.text = LS("private_information")
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
    let rowCount = tableView.numberOfRows(inSection: indexPath.section/*tableView.numberOfSections-1*/)
    return  (indexPath.row == rowCount - 1)
  }
}

extension EditProfileViewController: UITableViewDelegate {
  // method to run when table view cell is tapped
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print("You tapped cell number \(indexPath.row).")
  }
}

extension EditProfileViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return self.pickerDataSource.count
  }

  func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
    return self.pickerDataSource[row]
  }
}

struct ProfileItem {
  var key: String
  var iconImageName: String
  var placeHolder: String

  init(key: String, iconImageName: String, placeHolder: String) {
    self.key = key // User.swift에서의 정보에 해당하는 키값
    self.placeHolder = placeHolder
    self.iconImageName = iconImageName
  }
}

//struct ProfileItemGender {
//  enum genderType {
//    case none
//    case male
//    case female
//  }
//}
