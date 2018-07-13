//
//  ChangePasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/19/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var buttonConfirm: UIButton!
    
    @IBOutlet weak var textFieldOldPassword: UITextField!
    @IBOutlet weak var textFieldNewPassword: UITextField!
    @IBOutlet weak var textFieldConfirmNewPassword: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var labelOldPassword: UILabel!
    @IBOutlet weak var labelNewPassword: UILabel!
    @IBOutlet weak var labelConfirmPassword: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Change password"
        createBackButton()
        navigationController?.navigationBar.barTintColor = .white
        
        textFieldOldPassword.addTarget(self, action: #selector(oldPasswordDidChange), for: .editingChanged)
        textFieldNewPassword.addTarget(self, action: #selector(newPasswordDidChange), for: .editingChanged)
        textFieldConfirmNewPassword.addTarget(self, action: #selector(confirmPasswordDidChange), for: .editingChanged)
        
        setupButtonConfirm()
        hideTopBarLine()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        labelOldPassword.alpha = 0
        labelNewPassword.alpha = 0
        labelConfirmPassword.alpha = 0
    }

    @objc func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }
    
    @objc func oldPasswordDidChange() {
        setupButtonConfirm()
        
        DataManager.setupTextFieldLabel(textField: textFieldOldPassword, placeHolderLabel: labelOldPassword)
    }
    
    @objc func newPasswordDidChange() {
        setupButtonConfirm()
        DataManager.setupTextFieldLabel(textField: textFieldNewPassword, placeHolderLabel: labelNewPassword)
    }
    
    @objc func confirmPasswordDidChange() {
        setupButtonConfirm()
        DataManager.setupTextFieldLabel(textField: textFieldConfirmNewPassword, placeHolderLabel: labelConfirmPassword)
    }
    
    @IBAction func confirmTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func setupButtonConfirm() {
        
        if textFieldOldPassword.text!.count > 0 && textFieldNewPassword.text!.count > 0 &&
            textFieldNewPassword.text == textFieldConfirmNewPassword.text {
            buttonConfirm.setupButtonActiveState()
        }
        else {
            buttonConfirm.setupButtonDeactivateState()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
