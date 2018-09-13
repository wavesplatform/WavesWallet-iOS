//
//  DexInputTextField.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/12/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit
import AudioToolbox

private enum Constants {
    static let buttonDotFontSize: CGFloat = 17
    static let systemDotSoundID: SystemSoundID = 1103
}

protocol InputNumericTextFieldDelegate: AnyObject {

    func inputNumericTextField(_ textField: InputNumericTextField, didChangeValue value: Double)
}

final class InputNumericTextField: UITextField {

    private var externalDelegate: UITextFieldDelegate?

    var isShakeView: Bool = true
    weak var inputNumericDelegate: InputNumericTextFieldDelegate?
    
    override var delegate: UITextFieldDelegate? {
        didSet {
            externalDelegate = delegate
            super.delegate = self
        }
    }
    
    var value: Double {
        if let string = text {
            return (string as NSString).doubleValue
        }
        return 0
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        super.delegate = self
        placeholder = "0"
        addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private lazy var buttonDot: UIButton = {
        
        let button = UIButton(type: .system)
        button.frame = buttonDotFrame
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0)
        button.addTarget(self, action: #selector(keyboardDotTouchDown), for: .touchDown)
        button.addTarget(self, action: #selector(keyboardDotUpInside), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: Constants.buttonDotFontSize)
        button.setTitleColor(.black, for: .normal)
        button.setTitle(".", for: .normal)
        return button
    }()
    
    
    //MARK: - Methods
    
    func setStringValue(value: String) {
        setupAttributedText(text: value)
    }
    
    func addPlusValue() {
        if let string = text {
            var value = (string as NSString).doubleValue
            value += deltaValue
            
            let text = String(format: "%.0\(countDecimals)f", value)
            setupAttributedText(text: text)
        }
    }
    
    func addMinusValue() {
        if let string = text {
            var value = (string as NSString).doubleValue
            value -= deltaValue
            if value < 0 {
                value = 0
            }
            let text = String(format: "%.0\(countDecimals)f", value)
            setupAttributedText(text: text)
        }
    }
}

//MARK: - UI
private extension InputNumericTextField {
    
    func setupAttributedText(text: String) {
        attributedText = NSAttributedString.styleForBalance(text: text, font: font!)
    }
    
    func shakeTextFieldIfNeed() {
        if isShakeView {
            superview?.shakeView()
        }
    }
}

//MARK: - ButtonDot
private extension InputNumericTextField {
    
    @objc func keyboardDotTouchDown() {
        AudioServicesPlaySystemSound(Constants.systemDotSoundID)
    }
    
    @objc func keyboardDotUpInside() {
        
        if let text = self.text {
            if (text as NSString).range(of: ".").location != NSNotFound {
                shakeTextFieldIfNeed()
            }
            else {
                var string = text
                if text.count == 0 {
                    string = "0."
                }
                else {
                    string += "."
                }
                setupAttributedText(text: string)
            }
        }
    }
    
    @objc func addButtonDotToKeyboard() {
        DispatchQueue.main.async {
            UIApplication.shared.windows.last?.addSubview(self.buttonDot)
        }
    }
    
    func removeButtonDotFromKeyboard() {
        buttonDot.removeFromSuperview()
    }
    
    var buttonDotFrame: CGRect {
        
        let deltaButtonWidth: CGFloat = -8
        let bottomOffset : CGFloat = BiometricManager.type == .faceID ? 75 : 0
        
        let width = UIScreen.main.bounds.size.width / 3 + deltaButtonWidth
        let height : CGFloat = 48
        let topOffset: CGFloat = UIScreen.main.bounds.size.height - height - bottomOffset
        let leftOffset: CGFloat = 5
        
        return CGRect(x: leftOffset, y: topOffset, width: width, height: height)
    }
}

//MARK: - UITextFieldDelegate
extension InputNumericTextField: UITextFieldDelegate {
    
    @objc func textDidChange() {
        
        if let text = self.text {
            if text.count > 0 {
                setupAttributedText(text: text)
            }
            else {
                attributedText = nil
            }
            
            let value = Double(text) ?? 0
            inputNumericDelegate?.inputNumericTextField(self, didChangeValue: value)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        externalDelegate?.textFieldDidBeginEditing?(textField)
       
        NotificationCenter.default.addObserver(self, selector: #selector(addButtonDotToKeyboard), name: Notification.Name.UIKeyboardWillShow, object: nil)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        externalDelegate?.textFieldDidEndEditing?(textField)

        NotificationCenter.default.removeObserver(self)
        removeButtonDotFromKeyboard()
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        externalDelegate?.textFieldDidEndEditing?(textField, reason: reason)
        
        NotificationCenter.default.removeObserver(self)
        removeButtonDotFromKeyboard()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let externalDelegate = externalDelegate {
            if externalDelegate.responds(to: #selector(textField(_:shouldChangeCharactersIn:replacementString:))) {
                return externalDelegate.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
            }
        }

        if string == "" {
            return true
        }
        
        if let text = textField.text {
            if (text as NSString).range(of: ".").location == NSNotFound {
                if text.last == "0" && string == "0" && text.count == 1 {
                    
                    shakeTextFieldIfNeed()
                    return false
                }
                else if text.last == "0" && string != "." && text.count == 1 {
                    shakeTextFieldIfNeed()
                    return false
                }
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool  {
       
        if let externalDelegate = externalDelegate {
            if externalDelegate.responds(to: #selector(textFieldShouldReturn(_:))) {
                return externalDelegate.textFieldShouldReturn!(textField)
            }
        }
        resignFirstResponder()
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let externalDelegate = externalDelegate {
            if externalDelegate.responds(to: #selector(textFieldShouldBeginEditing(_:))) {
                return externalDelegate.textFieldShouldBeginEditing!(textField)
            }
        }
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let externalDelegate = externalDelegate {
            if externalDelegate.responds(to: #selector(textFieldShouldEndEditing(_:))) {
                return externalDelegate.textFieldShouldEndEditing!(textField)
            }
        }
        
        return true
    }
}

//MARK: - Calculation
private extension InputNumericTextField {
    
    var countDecimals: Int {
        
        var decimals = 0
        if let string = text {
            let string = string as NSString
            let range = string.range(of: ".")
            
            if range.location != NSNotFound {
                let substring = string.substring(from: range.location + 1)
                decimals = substring.count > 0 ? substring.count : 1
            }
        }
        
        return decimals
    }
    
    var deltaValue: Double {
        
        var deltaValue : Double = 1
        for _ in 0..<countDecimals {
            deltaValue *= 0.1
        }
        
        return deltaValue
    }

}
