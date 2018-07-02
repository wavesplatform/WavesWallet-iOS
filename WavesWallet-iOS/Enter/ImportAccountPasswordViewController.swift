//
//  ImportAccountPasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ImportAccountPasswordViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buttonContinue: UIButton!
    
    @IBOutlet weak var imageIcon: UIImageView!
    @IBOutlet weak var labelAddress: UILabel!
    
    @IBOutlet weak var labelAccountName: UILabel!
    @IBOutlet weak var labelCreatePassword: UILabel!
    @IBOutlet weak var labelConfirmPassword: UILabel!
    
    @IBOutlet weak var textFieldAccountName: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.setNavigationBarHidden(false, animated: true)
        createBackButton()
        setupSmallNavigationBar()
        hideTopBarLine()

        labelAccountName.alpha = 0
        labelCreatePassword.alpha = 0
        labelConfirmPassword.alpha = 0
        
        textFieldPassword.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
        textFieldConfirmPassword.addTarget(self, action: #selector(confirmPasswordDidChange), for: .editingChanged)
        textFieldAccountName.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        
        setupButtonContinue()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y >= 20 {
            navigationController?.navigationBar.shadowImage = nil
        }
        else {
            hideTopBarLine()
        }
    }
    
    func setupButtonContinue() {
        if textFieldAccountName.text!.count > 0 && textFieldPassword.text!.count > 0 &&
            textFieldPassword.text == textFieldConfirmPassword.text {
            buttonContinue.setupButtonActiveState()
        }
        else {
            buttonContinue.setupButtonDeactivateState()
        }
    }
    
    func nameDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldAccountName, placeHolderLabel: labelAccountName)
    }
    
    func passwordDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldPassword, placeHolderLabel: labelCreatePassword)
    }
    
    func confirmPasswordDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldConfirmPassword, placeHolderLabel: labelConfirmPassword)
    }
    
    
    @IBAction func continueTapped(_ sender: Any) {
        
    }
}
