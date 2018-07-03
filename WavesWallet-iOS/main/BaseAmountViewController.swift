//
//  BaseAmountViewController.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 5/14/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import AudioToolbox

class BaseAmountViewController: UIViewController, UITextFieldDelegate {
    
    var buttonDot: UIButton?
    var isShowKeyboardDotButton = false

    @IBOutlet weak var viewAmount: UIView!
    @IBOutlet weak var textFieldAmount: UITextField!

    @IBOutlet weak var scrollViewAmount: UIScrollView!
    @IBOutlet weak var heightScrollAmount: NSLayoutConstraint!

    let amounts = ["Use total balance", "0.100", "10.23", "11", "10.322"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: Notification.Name.UIKeyboardWillHide, object: nil)
        textFieldAmount.addTarget(self, action: #selector(amountChange), for: .editingChanged)
        viewAmount.addTableCellShadowStyle()

        setupScrollAmount()
    }

    func setupScrollAmount() {
        
        guard scrollViewAmount != nil else { return }
        
        let offset : CGFloat = 8
        var scrollWidth: CGFloat = 0
        
        for (index, value) in amounts.enumerated() {
            let button = ScrollButton(title: value)
            button.addTarget(self, action: #selector(amountTapped(_:)), for: .touchUpInside)
            button.tag = index
            button.frame.origin.x = scrollWidth
            scrollViewAmount.addSubview(button)
            scrollWidth += button.frame.size.width + offset
        }
        scrollViewAmount.contentSize.width = scrollWidth + offset
    }
    
    func amountTapped(_ sender: UIButton) {
        
        let index = sender.tag
        if index == 0 {
            textFieldAmount.attributedText = DataManager.attributedBalanceText(text: "0.100", font: textFieldAmount.font!)
        }
        else {
            let value = amounts[index]
            textFieldAmount.attributedText = DataManager.attributedBalanceText(text: value, font: textFieldAmount.font!)
        }
        
        heightScrollAmount.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.scrollViewAmount.alpha = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func amountChange() {
        
        let text = textFieldAmount.text!
        if text.count > 0 {
            textFieldAmount.attributedText = DataManager.attributedBalanceText(text: text, font: textFieldAmount.font!)
        }
        else {
            textFieldAmount.attributedText = nil
            
            guard heightScrollAmount != nil else { return }
            
            if heightScrollAmount.constant == 0 {
                heightScrollAmount.constant = 30
                UIView.animate(withDuration: 0.3) {
                    self.scrollViewAmount.alpha = 1
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func keyboardDotTouchDown() {
        AudioServicesPlaySystemSound(1103)
    }
    
    func keyboardDotUpInside() {
        
        if (textFieldAmount.text! as NSString).range(of: ".").location != NSNotFound {
            viewAmount.shakeView()
        }
        else {
            var text = textFieldAmount.text!
            if text.count == 0 {
                text = "0."
            }
            else {
                text += "."
            }
            
            textFieldAmount.attributedText = DataManager.attributedBalanceText(text: text, font: textFieldAmount.font!)
        }
    }
    
    
    func keyboardWillHide() {
        buttonDot?.removeFromSuperview()
    }
    
    func keyboardWillShow(_ notif: Notification) {
        
        if buttonDot == nil {
            let buttonWidth = Platform.ScreenWidth / 3 - 8
            let buttonHeight : CGFloat = 48
            let offset : CGFloat = Platform.isIphoneX ? 75 : 0
            buttonDot = UIButton(frame: CGRect(x: 5, y: UIScreen.main.bounds.size.height - buttonHeight - offset, width: buttonWidth, height: buttonHeight))
            buttonDot?.addTarget(self, action: #selector(keyboardDotTouchDown), for: .touchDown)
            buttonDot?.addTarget(self, action: #selector(keyboardDotUpInside), for: .touchUpInside)
            
            buttonDot?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            buttonDot?.setTitleColor(.black, for: .normal)
            buttonDot?.setTitle(".", for: .normal)
        }
        
        if isShowKeyboardDotButton {
            UIApplication.shared.windows.last?.addSubview(buttonDot!)
            buttonDot?.alpha = 0
            UIView.animate(withDuration: 0.3) {
                self.buttonDot?.alpha = 1
            }
        }
    }
    
    
    //MARK: - UITextFieldDelegate
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isShowKeyboardDotButton = false
        
        buttonDot?.removeFromSuperview()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string == "" {
            return true
        }
        
        if (textField.text! as NSString).range(of: ".").location == NSNotFound {
            if textField.text?.last == "0" && string == "0" && textField.text?.count == 1 {
                viewAmount.shakeView()
                return false
            }
            else if textField.text?.last == "0" && string != "." && textField.text?.count == 1 {
                viewAmount.shakeView()
                return false
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == textFieldAmount {
            isShowKeyboardDotButton = true
            
            if buttonDot?.superview == nil && buttonDot != nil {
                UIApplication.shared.windows.last?.addSubview(buttonDot!)
            }
            UIView.animate(withDuration: 0.3) {
                self.buttonDot?.alpha = 1
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
