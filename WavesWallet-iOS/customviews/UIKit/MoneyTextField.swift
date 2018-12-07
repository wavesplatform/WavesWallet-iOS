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
    static let maximumInputDigits = 10
}

protocol MoneyTextFieldDelegate: AnyObject {

    func moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money)
}

final class MoneyTextField: UITextField {

    private var externalDelegate: UITextFieldDelegate?
    private var textString: String {
        return text ?? ""
    }
    private var textNSString: NSString {
        return textString as NSString
    }

    override var delegate: UITextFieldDelegate? {
        didSet {
            externalDelegate = delegate
            super.delegate = self
        }
    }

    weak var moneyDelegate: MoneyTextFieldDelegate?
    var isShakeView: Bool = true
    private(set) var decimals: Int = 0
    private var hasSetDecimals = false
    
    var value: Money {
        if let decimal = Decimal(string: textString, locale: GlobalConstants.moneyLocale) {
            return Money(value: decimal, decimals)
        } else {
            return Money(0, decimals)
        }
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
}

//MARK: - Methods
extension MoneyTextField {
    
    // forceUpdateMoney need if we want call -> MoneyTextFieldDelegate: moneyTextField(_ textField: MoneyTextField, didChangeValue value: Money)
    func setDecimals(_ decimals: Int, forceUpdateMoney: Bool) {
        self.decimals = decimals
        hasSetDecimals = true
        
        if forceUpdateMoney {
            textDidChange()
        }
    }
    
    func setValue(value: Money) {
        setupAttributedText(text: formattedStringFrom(value))
    }
    
    func addPlusValue() {
        setValue(value: value.add(deltaValue))
    }
    
    func addMinusValue() {
        setValue(value: value.minus(deltaValue))
    }
    
    func clear() {
        decimals = 0
        hasSetDecimals = false
        text = nil
        textDidChange()
    }
}


//MARK: - Override
extension MoneyTextField {
    
    override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        return nil
    }
}

//MARK: - UI
private extension MoneyTextField {
    
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

private extension MoneyTextField {
    
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
        else if isEmptyDotAfterZero() {
            var string = textString
            string.remove(at: String.Index(encodedOffset: 0))
            setupAttributedText(text: string)
        }
    }
    
    func isEmptyDotAfterZero() -> Bool {
        
        if textString.count > 1 {
            
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
extension MoneyTextField: UITextFieldDelegate {
    
    @objc func textDidChange() {
        
        if textString.count > 0 {
            setupAttributedText(text: textNSString.replacingOccurrences(of: ",", with: "."))
            checkCorrectInputAfterRemoveText()
        }
        else {
            attributedText = nil
        }
    
        moneyDelegate?.moneyTextField(self, didChangeValue: value)
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
private extension MoneyTextField {
    
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
    
    var deltaValue: Double {
        
        var deltaValue : Double = 1
        for _ in 0..<countInputDecimals {
            deltaValue *= 0.1
        }
        
        return deltaValue
    }
}

//MARK: - InputValidation
private extension MoneyTextField {
    
    func isValidInput(input: String, inputRange: NSRange) -> Bool {
        
        if dotRange.location == NSNotFound {
            if textString.last == "0" && input == "0" && textString.count == 1 {
                shakeTextFieldIfNeed()
                return false
            }
            else if textString.last == "0" && input != "." && input != "," && textString.count == 1 {
                
                if inputRange.location == 0 && (input as NSString).integerValue > 0 {
                    
                    return true
                }
                shakeTextFieldIfNeed()
                return false
            }
        }

        if (input == "," || input == ".") && isExistDot {
            shakeTextFieldIfNeed()
            return false
        }
        
        if !isValidInputAfterDot(input: input, inputRange: inputRange) {
            shakeTextFieldIfNeed()
            return false
        }
        
        if !isValidInputBeforeDot(input: input, inputRange: inputRange) {
            shakeTextFieldIfNeed()
            return false
        }
        
        if !isValidBigNumber(input: input, inputRange: inputRange) {
            shakeTextFieldIfNeed()
            return false
        }
        
        return true
    }
    
    func isValidInputAfterDot(input: String, inputRange: NSRange) -> Bool {

        var isMaximumInputDecimals = false
        if hasSetDecimals {
            isMaximumInputDecimals = countInputDecimals >= decimals && input.count > 0

        }
        else {
            isMaximumInputDecimals = countInputDecimals >= decimals && decimals > 0 && input.count > 0
        }

        if isMaximumInputDecimals {
            if inputRange.location > dotRange.location {
                return false
            }
        }
        
        return true
    }
    
    func isValidBigNumber(input: String, inputRange: NSRange) -> Bool {
        
        if input == "." || input == "," {
            return true
        }
        
        if isExistDot {
            if inputRange.location < dotRange.location {
                let s = textNSString.substring(to: dotRange.location)
                return s.count + input.count <= Constants.maximumInputDigits
            }
        }
        else {
            return textString.count + input.count <= Constants.maximumInputDigits
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

//MARK: - NumberFormatter

private extension MoneyTextField {
    
    static func numberFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.decimalSeparator = "."
        return formatter
    }
    
    func formattedStringFrom(_ value: Money) -> String {
        let formatter = MoneyTextField.numberFormatter()
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = countInputDecimals
        return formatter.string(from: value.decimalValue as NSNumber) ?? ""
    }
}
