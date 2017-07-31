//
//  LoginViewController.swift
//  Alala
//
//  Created by hoemoon on 13/06/2017.
//  Copyright © 2017 team-meteor. All rights reserved.
//

import UIKit
import SnapKit

enum RequestType {
  case Register
  case Login
}

class LoginViewController: UIViewController {
  var height: Constraint?
  var requestType = RequestType.Login

  fileprivate let titleBackground = UIView().then {
    $0.isUserInteractionEnabled = false
    $0.backgroundColor = UIColor.gray
  }
  fileprivate let titleLabel = UILabel().then {
    $0.text = "Alala"
    $0.font = UIFont(name: "IowanOldStyle-BoldItalic", size: 30)
  }
  fileprivate let emailTextField = UITextField().then {
    $0.borderStyle = .roundedRect
    $0.placeholder = "Email"
    $0.autocorrectionType = .no
    $0.autocapitalizationType = .none
    $0.font = UIFont.systemFont(ofSize: 14)
  }
  fileprivate let passwordTextField = UITextField().then {
    $0.borderStyle = .roundedRect
    $0.placeholder = "Password"
    $0.isSecureTextEntry = true
    $0.font = UIFont.systemFont(ofSize: 14)
  }
  fileprivate let repeatPasswordTextField = UITextField().then {
    $0.borderStyle = .roundedRect
    $0.placeholder = "repeat Password"
    $0.isSecureTextEntry = true
    $0.font = UIFont.systemFont(ofSize: 14)
    $0.isHidden = true
  }
  fileprivate let authRequestButton = UIButton().then {
    $0.backgroundColor = $0.tintColor
    $0.layer.cornerRadius = 5
    $0.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
    $0.setTitle("Login", for: .normal)
  }
  fileprivate let signupLabel = UILabel().then {
    $0.backgroundColor = UIColor.clear
    $0.text = "Sign up"
    $0.font = UIFont.boldSystemFont(ofSize: 14)
    $0.textColor = $0.tintColor
  }

  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(true, animated: false)
    super.viewWillAppear(animated)
  }
  override func viewWillDisappear(_ animated: Bool) {
    self.navigationController?.setNavigationBarHidden(false, animated: false)
    super.viewWillDisappear(animated)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.emailTextField.addTarget(self, action: #selector(textFieldDidChangeText), for: .editingChanged)
    self.passwordTextField.addTarget(self, action: #selector(textFieldDidChangeText), for: .editingChanged)
    self.authRequestButton.addTarget(self, action: #selector(authRequestButtonDidTap), for: .touchUpInside)
    let tap = UITapGestureRecognizer(target: self, action: #selector(signupLabelDidTap))
    let dismissTap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    view.addGestureRecognizer(dismissTap)
    signupLabel.isUserInteractionEnabled = true
    self.signupLabel.addGestureRecognizer(tap)

    self.view.addSubview(self.titleBackground)
    self.titleBackground.addSubview(self.titleLabel)
    self.view.addSubview(self.emailTextField)
    self.view.addSubview(self.passwordTextField)
    self.view.addSubview(self.repeatPasswordTextField)
    self.view.addSubview(self.authRequestButton)
    self.view.addSubview(self.signupLabel)

    self.titleBackground.snp.makeConstraints { (make) in
      make.top.equalTo(self.view)
      make.left.equalTo(self.view)
      make.right.equalTo(self.view)
      make.height.equalTo(108)
    }
    self.titleLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.titleBackground)
      make.centerY.equalTo(self.titleBackground)
    }
    self.emailTextField.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.top.equalTo(self.titleBackground.snp.bottom).offset(50)
      make.width.equalTo(self.view.frame.width * 0.8)
      make.height.equalTo(50)
    }
    self.passwordTextField.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.top.equalTo(self.emailTextField.snp.bottom).offset(15)
      make.width.equalTo(self.view.frame.width * 0.8)
      make.height.equalTo(50)
    }
    self.repeatPasswordTextField.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.top.equalTo(self.passwordTextField.snp.bottom).offset(15)
      make.width.equalTo(self.view.frame.width * 0.8)
      height = make.height.equalTo(0).constraint
    }
    self.authRequestButton.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.top.equalTo(self.repeatPasswordTextField.snp.bottom).offset(30)
      make.width.equalTo(self.view.frame.width * 0.8)
      make.height.equalTo(50)
    }
    self.signupLabel.snp.makeConstraints { (make) in
      make.centerX.equalTo(self.view)
      make.bottom.equalTo(self.view).offset(-10)
    }
  }

  func textFieldDidChangeText(_ textField: UITextField) {
    textField.backgroundColor = .white
  }

  func dismissKeyboard() {
    view.endEditing(true)
  }

  func authRequestButtonDidTap() {
    guard let email = self.emailTextField.text, !email.isEmpty else {
      return
    }
    guard let password = self.passwordTextField.text, !password.isEmpty else {
      return
    }
    self.emailTextField.isEnabled = false
    self.passwordTextField.isEnabled = false
    self.authRequestButton.isEnabled = false
    self.authRequestButton.alpha = 0.4

    if self.requestType == .Login {
      AuthService.instance.login(email: email, password: password, completion: { (success) in
        if success {
          AuthService.instance.me(completion: { (user) in
            if user != nil {
              DispatchQueue.main.async {
                NotificationCenter.default.post(name: .presentMainTabBar, object: nil)
              }
            }
          })
        } else {
          print("Login failed")
          DispatchQueue.main.async {
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.authRequestButton.isEnabled = true
            self.authRequestButton.alpha = 1
          }
        }
      })
    } else {
      AuthService.instance.register(email: email, password: password) { (success, message) in
        if success {
          print(message)
          AuthService.instance.login(email: email, password: password, completion: { (success) in
            if success {
              DispatchQueue.main.async {
                let afterRegisterVC = AfterRegisterViewController()
                self.navigationController?.pushViewController(afterRegisterVC, animated: true)
              }

            } else {
              print(message)
              DispatchQueue.main.async {
                self.emailTextField.isEnabled = true
                self.passwordTextField.isEnabled = true
                self.authRequestButton.isEnabled = true
                self.authRequestButton.alpha = 1
              }
            }
          })
        } else {
          print(message)
          DispatchQueue.main.async {
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.authRequestButton.isEnabled = true
            self.authRequestButton.alpha = 1
          }
        }
      }
    }
  }

  func signupLabelDidTap() {
    if repeatPasswordTextField.isHidden {
      self.authRequestButton.setTitle("Sign up", for: .normal)
      self.signupLabel.text = "Log in"
      self.requestType = RequestType.Register
      self.repeatPasswordTextField.snp.makeConstraints { (make) in
        height?.deactivate()
        height = make.height.equalTo(50).constraint
      }
    } else {
      self.authRequestButton.setTitle("Log in", for: .normal)
      self.signupLabel.text = "Sign up"
      self.requestType = RequestType.Login
      self.repeatPasswordTextField.snp.makeConstraints { (make) in
        height?.deactivate()
        height = make.height.equalTo(0).constraint
      }
    }
    self.repeatPasswordTextField.isHidden = !repeatPasswordTextField.isHidden
  }
}
