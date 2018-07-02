//
//  ImportWelcomeBackViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 6/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

class ImportWelcomeBackViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var buttonContinue: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var labelAccountSeed: UILabel!
    @IBOutlet weak var viewNoAddress: UIView!
    
    @IBOutlet weak var labelTitleSmall: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelTitleBig: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        buttonContinue.setupButtonDeactivateState()
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        labelAccountSeed.alpha = 0
        labelAddress.alpha = 0
        viewSeparator.isHidden = true
        labelTitleSmall.isHidden = true
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func textFieldDidChange() {
        if textField.text!.count > 0 {
            buttonContinue.setupButtonActiveState()
            
            if labelAddress.alpha == 0 {
                UIView.animate(withDuration: 0.3) {
                    self.labelAddress.alpha = 1
                    self.viewNoAddress.alpha = 0
                }
            }
        }
        else {
            buttonContinue.setupButtonDeactivateState()

            if labelAddress.alpha == 1 {
                UIView.animate(withDuration: 0.3) {
                    self.labelAddress.alpha = 0
                    self.viewNoAddress.alpha = 1
                }
            }
        }
        
        DataManager.setupTextFieldLabel(textField: textField, placeHolderLabel: labelAccountSeed)
    }
    
    @IBAction func continueTapped(_ sender: Any) {
        textField.resignFirstResponder()
        hideTopBarLine()
        let controller = storyboard?.instantiateViewController(withIdentifier: "ImportAccountPasswordViewController") as! ImportAccountPasswordViewController
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let showSmallTitle = scrollView.contentOffset.y >= 30
        
        if showSmallTitle {
            viewSeparator.isHidden = false
            labelTitleBig.isHidden = true
            labelTitleSmall.isHidden = false
        }
        else {
            viewSeparator.isHidden = true
            labelTitleBig.isHidden = false
            labelTitleSmall.isHidden = true
        }
    }
    
    func keyboardWillHide() {
        scrollView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
