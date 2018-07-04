//
//  AccountPasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/1/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class AccountPasswordViewController: UIViewController {

    @IBOutlet weak var buttonSignIn: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var labelPassword: UILabel!
    
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
    
    }
    
}
