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
    $0.setTitle(LS("change_profile_photo"), for: .normal)
    $0.addTarget(self, action: #selector(changePhotoButtonTap), for: .touchUpInside)
    $0.setTitleColor(UIColor.blue, for: .normal)
  }
  let contentTableView = UITableView()

  var genderPicker: UIPickerView?
  var pickerDataSource: [String]?

  var allProfileItemArray: [[String:[ProfileItem]]] = []

  let tableViewDefaultHeight: CGFloat = 44.0
  var placeholderTextViewHeight: CGFloat = 44.0

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
    self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: LS("cancel"),
                                                            style: UIBarButtonItemStyle.plain,
                                                            target: self,
                                                            action: #selector(backNaviButtonTap))
    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: LS("done"),
                                                             style: UIBarButtonItemStyle.done,
                                                             target: self,
                                                             action: #selector(doneNaviButtonTap))
    self.title = LS("edit_profile")
  }

  /**
   * 테이블에 출력될 프로필 아이템 설정
   *
   * - Note : e.g. ["Section1":[Section1의 Row1,Section1의 Row2...],"Section2":[Section2의 Row1,Section1의 Row2...]]
   */
  func setupProfileItem() {
    allProfileItemArray = [
      ["": [ProfileItem(key: "displayName", iconImageName: "nametag", placeHolder: LS("name")),
            ProfileItem(key: "profileName", iconImageName: "personal", placeHolder: LS("username")),
            ProfileItem(key: "website", iconImageName: "website", placeHolder: LS("website")),
            ProfileItem(key: "bio", iconImageName: "information", placeHolder: LS("bio"))]],
      ["PRIVATE INFORMATION":
           [ProfileItem(key: "email", iconImageName: "email", placeHolder: LS("email")),
            ProfileItem(key: "Phone", iconImageName: "phone", placeHolder: LS("phone")),
            ProfileItem(key: "gender", iconImageName: "gender", placeHolder: LS("gender"))]]
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

    if (tempMe?.profileName?.characters.count)! <= 0 {
      let alertView = UIAlertController(title: "", message: LS("username_needed"), preferredStyle: UIAlertControllerStyle.alert)
      alertView.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
      self.present(alertView, animated: true, completion: nil)
      return
    }

    if User.isEqual(l:me!, r:tempMe!) {
      //--- 변경사항 없음
      self.backNaviButtonTap()
    } else {
      //--- 변경사항 존재
      if self.tempMe?.profilePhotoId?.characters.count == 0 {
        var imageArray = [UIImage]()
        imageArray.append(currentProfileImageView.image!)
        MultipartService.uploadMultipart(multiPartDataArray: imageArray, progressCompletion: nil) { (imageId) in
          self.tempMe?.profilePhotoId = imageId[0]
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
      ProfileItemBio.indexPath = indexPath
      cellReuseIdentifier = EditProfileTableViewCell.textViewCell
    } else {
      cellReuseIdentifier = EditProfileTableViewCell.textFieldCell
    }

    let cell: EditProfileTableViewCell = contentTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! EditProfileTableViewCell

    if cell.textView.superview != nil {
      cell.textView.placeholderDelgate = self
    }

    if profileItem.key=="gender" {
      ProfileItemGender.indexPath = indexPath
      let gender = tempMe?.value(forKey: profileItem.key as String) as! String
      cell.setText(text: ProfileItemGender.getGenderValue(gender))
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
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if ProfileItemBio.indexPath == indexPath {
      return max(tableViewDefaultHeight, placeholderTextViewHeight)
    } else {
      return tableViewDefaultHeight
    }

  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //print("You tapped cell number \(indexPath.row).")
    let dic: [String:[ProfileItem]] = allProfileItemArray[indexPath.section]
    let arr: [ProfileItem] = dic.values.first!
    let profileItem: ProfileItem = arr[indexPath.row]

    if profileItem.key=="gender" {
      self.pickerDataSource = ProfileItemGender.getGenderList()
      self.genderPicker = UIPickerView()
      self.genderPicker?.backgroundColor = UIColor.gray
      self.genderPicker?.dataSource = self
      self.genderPicker?.delegate = self
      self.view.addSubview(self.genderPicker!)
      self.genderPicker?.snp.makeConstraints({ (make) in
        make.height.equalTo(200)
        make.left.equalTo(self.view)
        make.right.equalTo(self.view)
        make.bottom.equalTo(self.view)
      })
    }
  }
}

extension EditProfileViewController: UIPlaceholderTextViewDelegate {
  func placeholderTextViewHeightChanged(_ height: CGFloat) {
    placeholderTextViewHeight = height + 8 // textview height + margin 8
    self.contentTableView.beginUpdates()
    self.contentTableView.endUpdates()
  }
}

extension EditProfileViewController: UIPickerViewDataSource {
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }

  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return (self.pickerDataSource?.count)!
  }
}

extension EditProfileViewController: UIPickerViewDelegate {
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return self.pickerDataSource?[row]
  }

  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    let selectedValue = self.pickerDataSource?[row]
    self.tempMe?.gender = ProfileItemGender.getGenderKey(selectedValue!)
    self.contentTableView.reloadRows(at: [ProfileItemGender.indexPath!], with: .automatic)
    self.genderPicker?.removeFromSuperview()
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

struct ProfileItemBio {
  static var indexPath: IndexPath?
}

struct ProfileItemGender {

  static let map: NSDictionary = ["": LS("gender_none"), "M": LS("gender_male"), "F": LS("gender_female")]

  static var indexPath: IndexPath?

  /**
   * 화면에 출력될 성별 목록을 반환
   *
   * - returns : 성별 목록 Array (입력되지 않음, 남성, 여성)
   */
  static func getGenderList() -> [String] {
    return ProfileItemGender.map.allValues as! [String]
  }

  /**
   * User객체에 저장된 값에 해당하는 화면 출력용 문구를 반환
   *
   * - param : User객체에 저장되는 gender key (빈 String 혹은 M이나 F)
   * - returns : key값에 매칭되어 실제 사용자가 화면에서 보는 문구 (입력되지 않음, 남성, 여성)
   */
  static func getGenderValue(_ key: String) -> String {
    var value = ProfileItemGender.map.value(forKey: key) as! String
    if value.characters.count <= 0 {
      value = LS("gender_none") // default value
    }
    return value
  }

  /**
   * 화면에 출력된 Gender정보를 User객체에 넣을 수 있는 key로 변환
   *
   * - param : 실제 사용자가 화면에서 보는 문구 (입력되지 않음, 남성, 여성)
   * - returns : User객체에 저장되는 gender key (빈 String 혹은 M이나 F)
   */
  static func getGenderKey(_ value: String) -> String {
    let keys = ProfileItemGender.map.allKeys(for: value)
    return keys.first as! String
  }
}
