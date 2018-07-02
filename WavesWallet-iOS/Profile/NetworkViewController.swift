//
//  NetworkViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class NetworkViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var textFieldNodeAddress: UITextField!
    @IBOutlet weak var labelNodeAddress: UILabel!
    
    @IBOutlet weak var textFieldMatcherAddress: UITextField!
    @IBOutlet weak var labelMatcherAddress: UILabel!
    
    @IBOutlet weak var labelSpam: UILabel!
    @IBOutlet weak var textFieldSpam: UITextField!
    @IBOutlet weak var switchControl: UISwitch!
    
    @IBOutlet weak var buttonSave: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.barTintColor = .white
        title = "Network"
        hideTopBarLine()
        createBackButton()
        
        setupButtonState()
        textFieldNodeAddress.addTarget(self, action: #selector(nodeDidChange), for: .editingChanged)
        textFieldMatcherAddress.addTarget(self, action: #selector(matcherDidChange), for: .editingChanged)
        textFieldSpam.addTarget(self, action: #selector(spamDidChange), for: .editingChanged)
        
        labelSpam.alpha = 0
        labelMatcherAddress.alpha = 0
        labelNodeAddress.alpha = 0

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func nodeDidChange() {
        DataManager.setupTextFieldLabel(textField: textFieldNodeAddress, placeHolderLabel: labelNodeAddress)
    }
    
    func matcherDidChange() {
        DataManager.setupTextFieldLabel(textField: textFieldMatcherAddress, placeHolderLabel: labelMatcherAddress)
    }
    
    func spamDidChange() {
        DataManager.setupTextFieldLabel(textField: textFieldSpam, placeHolderLabel: labelSpam)
    }
    
    func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint(x: 0, y: -0.5), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        setupTopBarLine()
    }
    
    func setupButtonState() {
        buttonSave.setupButtonDeactivateState()
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        
    }
    
    @IBAction func setDefaultTapped(_ sender: Any) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
