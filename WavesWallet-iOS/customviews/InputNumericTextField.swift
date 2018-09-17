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
    static let maximumInt64SizeDigits = 18
    static let localeIdentifier = "es_US"
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
    
    private var maximumInputDigits: Int {
        return Constants.maximumInt64SizeDigits - decimals
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
        
        if let decimal = Decimal(string: textString, locale: Locale(identifier: Constants.localeIdentifier)) {
            return Money(Int64(truncating: decimal * Decimal(10 ^^ decimals) as NSNumber), decimals)
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
        keyboardType = .decimalPad
    }
   
    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        return nil
    }
    
    //MARK: - Methods
    
    func setValue(value: Money) {
        decimals = value.decimals
        
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = decimals
        f.minimumFractionDigits = countInputDecimals
        f.usesGroupingSeparator = false
        f.decimalSeparator = "."
        
        let result = f.string(from: Decimal(value.amount) / pow(10, decimals) as NSNumber) ?? ""
        
        setupAttributedText(text: result)
    }
    
    func addPlusValue() {
        
//        let text = String(format: "%.0\(countInputDecimals)f", value.decimalValue + deltaValue)
        
        setValue(value: Money(value.decimalValue + deltaValue, decimals: decimals))
    }
    
    func addMinusValue() {
        
        var decimal = value.decimalValue + deltaValue
        if decimal < 0 {
            decimal = 0
        }
        setValue(value: Money(decimal, decimals: decimals))
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

//MARK: - Check after input

private extension InputNumericTextField {
    
    func checkCorrectInputAfterRemoveText() {
        
        if isExistDot {
            
            let isEmptyFieldBeforeDot = textNSString.substring(to: dotRange.location).count == 0
            
            if isEmptyFieldBeforeDot {
                var string = textString
                string.insert("0", at: String.Index(encodedOffset: 0))
                setupAttributedText(text: string)
                
                if textString == "0." {
                    if let range = selectedTextRange, let from = position(from: range.start, offset: 1) {
                        selectedTextRange = textRange(from: from, to: from)
                    }
                }
            }
        }
        else if isEmptyDotAfterZero(text: textString) {
            var string = textString
            string.remove(at: String.Index(encodedOffset: 0))
            setupAttributedText(text: string)
        }
    }
    
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
}

//MARK: - UITextFieldDelegate
extension InputNumericTextField: UITextFieldDelegate {
    
    @objc func textDidChange() {
        
        if textString.count > 0 {
            setupAttributedText(text: textNSString.replacingOccurrences(of: ",", with: "."))
            checkCorrectInputAfterRemoveText()
        }
        else {
            attributedText = nil
        }
        
        print("int", value.amount)

        
        inputNumericDelegate?.inputNumericTextField(self, didChangeValue: value)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        externalDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        externalDelegate?.textFieldDidEndEditing?(textField)
    }
    
    @available(iOS 10.0, *)
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        externalDelegate?.textFieldDidEndEditing?(textField, reason: reason)
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
    
    var isExistDot: Bool {
        return dotRange.location != NSNotFound
    }
    
    var countInputDecimals: Int {
        
        var decimals = 0
        
        if isExistDot {
            let substring = textNSString.substring(from: dotRange.location + 1)
            decimals = substring.count > 0 ? substring.count : 1
        }
        
        return decimals
    }
    
    var deltaValue: Decimal {
        
        var deltaValue : Decimal = 1
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
            else if textString.last == "0" && input != "." && input != "," && textString.count == 1 {
                shakeTextFieldIfNeed()
                return false
            }
        }
        else if (input == "," || input == ".") && isExistDot {
            shakeTextFieldIfNeed()
            return false
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
        
        if isExistDot && textString.count > 1 {

            if input == "0" && inputRange.location == 0 {
                shakeTextFieldIfNeed()
                return false
            }

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
