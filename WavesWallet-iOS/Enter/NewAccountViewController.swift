//
//  NewAccountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class NewAccountViewController: UIViewController {

    @IBOutlet var avatarsSpaceConstraints: [NSLayoutConstraint]!
    
    @IBOutlet var dottedViews: [DottedRoundView]!
    
    @IBOutlet weak var labelAccountName: UILabel!
    @IBOutlet weak var textFieldAccountName: UITextField!
    @IBOutlet weak var labelCreatePassword: UILabel!
    @IBOutlet weak var textFieldCreatePassword: UITextField!
    @IBOutlet weak var labelConfirmPassword: UILabel!
    @IBOutlet weak var textFieldConfirmPassword: UITextField!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var isSelectedAva = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.barTintColor = .white
        
        title = "New Account"
        setupBigNavigationBar()
        createBackButton()
        hideTopBarLine()
        
        if Platform.isIphone5 {
            for constraint in avatarsSpaceConstraints {
                constraint.constant = 7
            }
        }
        
        labelAccountName.alpha = 0
        labelCreatePassword.alpha = 0
        labelConfirmPassword.alpha = 0
        
        setupButtonContinue()
       
        textFieldCreatePassword.addTarget(self, action: #selector(createPasswordDidChange), for: .editingChanged)
        textFieldConfirmPassword.addTarget(self, action: #selector(confirmPasswordDidChange), for: .editingChanged)
        textFieldAccountName.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func accountAvatarTapped(_ sender: Any) {
    
        isSelectedAva = true
        
        let index = (sender as! UIButton).tag
        
        for view in dottedViews {
            if view.tag == index {
                view.isSelectedMode = true
            }
            else {
                view.isSelectedMode = false
                view.isNotDraw = true
            }
            view.setNeedsDisplay()
        }
        
        setupButtonContinue()
    }
    
    @objc func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    @objc func nameDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldAccountName, placeHolderLabel: labelAccountName)
    }
    
    @objc func confirmPasswordDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldConfirmPassword, placeHolderLabel: labelConfirmPassword)

    }
    
    @objc func createPasswordDidChange() {
        setupButtonContinue()
        DataManager.setupTextFieldLabel(textField: textFieldCreatePassword, placeHolderLabel: labelCreatePassword)
    }
    
    func setupButtonContinue() {
        if textFieldAccountName.text!.count > 0 && textFieldCreatePassword.text!.count > 0 &&
            textFieldCreatePassword.text == textFieldConfirmPassword.text  && isSelectedAva {
            buttonContinue.setupButtonActiveState()
        }
        else {
            buttonContinue.setupButtonDeactivateState()
        }
    }
    
    @IBAction func continueTapped(_ sender: Any) {
    
        let controller = storyboard?.instantiateViewController(withIdentifier: "NewAccountSecretPhraseViewController") as! NewAccountSecretPhraseViewController
        navigationController?.pushViewControllerAndSetLast(controller)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
