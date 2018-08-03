//
//  AccountPasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol AccountPasswordViewControllerDelegate: class {
    
    func accountPasswordViewControllerDidSuccessEnter()
}

class AccountPasswordViewController: UIViewController {

    var delegate: AccountPasswordViewControllerDelegate?
    
    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelPassword: UILabel!
    
    var isLoginMode = false
    
    private let password = "123456"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createBackButton()
        
        labelPassword.alpha = 0
        textField.addTarget(self, action: #selector(textFieldPasswordDidChange), for: .editingChanged)
        buttonSignIn.setupButtonDeactivateState()
    }

    @objc func textFieldPasswordDidChange() {
        DataManager.setupTextFieldLabel(textField: textField, placeHolderLabel: labelPassword)
        if textField.text!.count > 0 {
            buttonSignIn.setupButtonActiveState()
        }
        else {
            buttonSignIn.setupButtonDeactivateState()
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
    
        if textField.text == password {
            if isLoginMode {
                AppDelegate.shared().menuController.setContentViewController(MainTabBarController(), animated: true)
            }
            else {
                delegate?.accountPasswordViewControllerDidSuccessEnter()
                navigationController?.popViewController(animated: true)
            }
        }
        else {
            presentBasicAlertWithTitle(title: "Incorrect password")
        }
    }
    
}
