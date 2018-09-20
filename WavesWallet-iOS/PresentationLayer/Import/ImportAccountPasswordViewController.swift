//
//  ImportAccountPasswordViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class ImportAccountPasswordViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var buttonContinue: UIButton!
    
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var labelAddress: UILabel!
    
    @IBOutlet private weak var labelAccountName: UILabel!
    @IBOutlet private weak var labelCreatePassword: UILabel!
    @IBOutlet private weak var labelConfirmPassword: UILabel!
    
    @IBOutlet private weak var textFieldAccountName: UITextField!
    @IBOutlet private weak var textFieldPassword: UITextField!
    @IBOutlet private weak var textFieldConfirmPassword: UITextField!

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

    func setupButtonContinue() {
        if textFieldAccountName.text!.count > 0 && textFieldPassword.text!.count > 0 &&
            textFieldPassword.text == textFieldConfirmPassword.text {
            buttonContinue.setupButtonActiveState()
        }
        else {
            buttonContinue.setupButtonDeactivateState()
        }
    }
    
    @objc func nameDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldAccountName, placeHolderLabel: labelAccountName)
    }
    
    @objc func passwordDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldPassword, placeHolderLabel: labelCreatePassword)
    }
    
    @objc func confirmPasswordDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldConfirmPassword, placeHolderLabel: labelConfirmPassword)
    }

    @IBAction func continueTapped(_ sender: Any) {
        
        let controller = StoryboardManager.ProfileStoryboard().instantiateViewController(withIdentifier: "PasscodeViewController") as! PasscodeViewController
        controller.isCreatePasswordMode = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ImportAccountPasswordViewController: UIScrollViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y >= 20 {
            navigationController?.navigationBar.shadowImage = nil
        }
        else {
            hideTopBarLine()
        }
    }
}
