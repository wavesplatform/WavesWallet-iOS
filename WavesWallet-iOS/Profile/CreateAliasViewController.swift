//
//  CreateAliasViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/26/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class CreateAliasViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonCreate: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "New alias"
        setupBigNavigationBar()
        hideTopBarLine()
        createBackButton()
        textField.addTarget(self, action: #selector(nameDidChange), for: .editingChanged)
        labelName.alpha = 0
        buttonCreate.setupButtonDeactivateState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @IBAction func createTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func nameDidChange() {
        DataManager.setupTextFieldLabel(textField: textField, placeHolderLabel: labelName)
        
        if textField.text!.count > 0 {
            buttonCreate.setupButtonActiveState()
        }
        else {
            buttonCreate.setupButtonDeactivateState()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
