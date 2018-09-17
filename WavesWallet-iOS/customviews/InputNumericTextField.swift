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
    
    static let maximumInputDigits = 8
}

protocol InputNumericTextFieldDelegate: AnyObject {

    func inputNumericTextField(_ textField: InputNumericTextField, didChangeValue value: Money)
}

final class InputNumericTextField: UITextField {

    private var externalDelegate: UITextFieldDelegate?

    private var textNSString: NSString {
        return textString as NSString
    }
    
    private var textString: String {
        return text ?? ""
    }
    
    override var delegate: UITextFieldDelegate? {
        didSet {
            externalDelegate = delegate
            super.delegate = self
        }
    }
    
    var isShakeView: Bool = true
    weak var inputNumericDelegate: InputNumericTextFieldDelegate?
    var decimals: Int = 0

    var value: Money {
        
        if let d = Decimal(string: textString, locale: Locale.current) {
            return Money(Int64(truncating: d * Decimal(10 ^^ decimals) as NSNumber), decimals)
        } else {
            return Money(0)
        }
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
        keyboardType = .numberPad
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
    
    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        return nil
    }
    
    //MARK: - Methods
    
    func setValue(value: Money) {
        decimals = value.decimals
        setupAttributedText(text: value.displayTextFull)
    }
    
//    func setStringValue(value: String) {
//        setupAttributedText(text: value)
//    }
    
    func addPlusValue() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.maximumFractionDigits = decimals
        numberFormatter.minimumIntegerDigits = decimals
        numberFormatter.decimalSeparator = "."
        numberFormatter.usesGroupingSeparator = false
        
        
        let number = numberFormatter.number(from: textString)!
        
        print("number", number)
        print("numberDouble", number.doubleValue)
        print("value", textNSString.doubleValue)

        var value = textNSString.doubleValue
        value += deltaValue

        let text = String(format: "%.0\(countInputDecimals)f", value)
        setupAttributedText(text: text)
    }
    
    func addMinusValue() {
        var value = textNSString.doubleValue
        value -= deltaValue
        if value < 0 {
            value = 0
        }
        let text = String(format: "%.0\(countInputDecimals)f", value)
        setupAttributedText(text: text)
    }
}

//MARK: - UI
private extension InputNumericTextField {
    
    func setupAttributedText(text: String) {
        let range = selectedTextRange
        attributedText = NSAttributedString.styleForBalance(text: text, font: font!)
        selectedTextRange = range
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
        
        if dotRange.location != NSNotFound {
            shakeTextFieldIfNeed()
        }
        else {
            if let selectedRange = selectedTextRange {
                var string = textString

                let rangePosition = offset(from: beginningOfDocument, to: selectedRange.start)
                
                let textBeforeDot = textNSString.substring(to: rangePosition)

                let insertString = textBeforeDot.count == 0 ? "0." : "."
                let rangeOffset = textBeforeDot.count == 0 ? 2 : 1
                
                string.insert(contentsOf: insertString, at: String.Index(encodedOffset: rangePosition))
                setupAttributedText(text: string)
                
                if let range = selectedTextRange {
                    if let from = position(from: range.start, offset: rangeOffset) {
                        selectedTextRange = textRange(from: from, to: from)
                    }
                }
            }
        }
    }
    
    func checkCorrectInputAfterRemoveText() {
        
        func isEmptyDotAfterZero(text: String) -> Bool {
            
            if text.count > 1 {
                
                let firstCharacter = textNSString.substring(to: 1)
                let secondCharacter = (textNSString.substring(from: 1) as NSString).substring(to: 1)
                if firstCharacter == "0" && secondCharacter != "." {
                    return true
                }
            }
            return false
        }
        
        
        if dotRange.location != NSNotFound {
            
            let isEmptyFieldBeforeDot = textNSString.substring(to: dotRange.location).count == 0
            
            if isEmptyFieldBeforeDot {
                var string = textString
                string.insert("0", at: String.Index(encodedOffset: 0))
                setupAttributedText(text: string)
            }
        }
        else if isEmptyDotAfterZero(text: textString) {
            var string = textString
            string.remove(at: String.Index(encodedOffset: 0))
            setupAttributedText(text: string)
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
        
        if textString.count > 0 {
            setupAttributedText(text: textString)
            checkCorrectInputAfterRemoveText()
        }
        else {
            attributedText = nil
        }
        
//        print("displayText", value.displayTextNoGrouping)
        print("int", value.amount)

        
        inputNumericDelegate?.inputNumericTextField(self, didChangeValue: value)
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
        
        return isValidInput(input: string, inputRange: range)
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
    
    var dotRange: NSRange {
        return textNSString.range(of: ".")
    }
    
    var countInputDecimals: Int {
        
        var decimals = 0
        
        if dotRange.location != NSNotFound {
            let substring = textNSString.substring(from: dotRange.location + 1)
            decimals = substring.count > 0 ? substring.count : 1
        }
        
        return decimals
    }
    
    var deltaValue: Double {
        
        var deltaValue : Double = 1
        for _ in 0..<countInputDecimals {
            deltaValue *= 0.1
        }
        
        return deltaValue
    }
}

//MARK: - InputValidation
private extension InputNumericTextField {
    
    func isValidInput(input: String, inputRange: NSRange) -> Bool {
        
        if dotRange.location == NSNotFound {
            if textString.last == "0" && input == "0" && textString.count == 1 {
                shakeTextFieldIfNeed()
                return false
            }
            else if textString.last == "0" && input != "." && textString.count == 1 {
                shakeTextFieldIfNeed()
                return false
            }
        }
        else if countInputDecimals >= decimals && decimals > 0 && input.count > 0 {
            if inputRange.location > dotRange.location {
                shakeTextFieldIfNeed()
                return false
            }
            else if !isValidInputBeforeDot(input: input, inputRange: inputRange) {
                shakeTextFieldIfNeed()
                return false
            }
        }
        else if !isValidInputBeforeDot(input: input, inputRange: inputRange) {
            shakeTextFieldIfNeed()
            return false
        }
        return true
    }
    
    
    func isValidInputBeforeDot(input: String, inputRange: NSRange) -> Bool {
        
        if dotRange.location != NSNotFound && textString.count > 1 {

            let substring = textNSString.substring(to: dotRange.location + dotRange.length)
            
            if (substring == "0." && inputRange.location == 1) ||
                (substring == "0." && input == "0" && inputRange.location == 0) {
                
                shakeTextFieldIfNeed()
                return false
            }
        }
        return true
    }
}
