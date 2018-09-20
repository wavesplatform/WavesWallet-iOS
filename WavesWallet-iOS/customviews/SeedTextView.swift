//
//  NewAccountInputTextField.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class InputTextField: UIView, NibOwnerLoadable {

    enum Kind {
        case password
        case newPassword
        case text
    }

    struct Model {
        let title: String
        let kind: Kind
        let placeholder: String?
    }

    @IBOutlet private var placeHolder: UILabel!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var textViewValue: UITextView!    
    @IBOutlet private var eyeButton: UIButton!
    private var originalText: String?

    var value: String? {
        return originalText
    }

    private var isHiddenTitleLabel: Bool = true
    private var isSecureTextEntry: Bool = false {
        didSet {
            textViewValue.isSecureTextEntry = isSecureTextEntry
            if #available(iOS 10.0, *) {
                textViewValue.textContentType = UITextContentType("")
            }
            if isSecureTextEntry {
                eyeButton.setImage(Images.eyeopen24Basic500.image, for: .normal)
            } else {
                eyeButton.setImage(Images.eyeclsoe24Basic500.image, for: .normal)
            }
            updateTextView(originalText)
        }
    }

    var lineNumber: Int = 1 {
        didSet {
            textViewValue.textContainer.maximumNumberOfLines = lineNumber
        }
    }
    var valueValidator: ((String?) -> String?)?
    var changedValue: ((Bool,String?) -> Void)?
    var textFieldShouldReturn: ((InputTextField) -> Void)?

    var returnKey: UIReturnKeyType? {
        didSet {
            textViewValue.returnKeyType = returnKey ?? .done
        }
    }

    private(set) var isValidValue: Bool = false

    private var kind: Kind?

    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
        textViewValue.textContainerInset = .zero
        textViewValue.textContainer.lineFragmentPadding = 0
        textViewValue.delegate = self
        eyeButton.addTarget(self, action: #selector(tapEyeButton), for: .touchUpInside)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        return textViewValue.becomeFirstResponder()
    }

    @objc func keyboardWillHide() {
        checkValidValue()
    }

    @objc private func tapEyeButton() {
        isSecureTextEntry = !isSecureTextEntry
    }

    @objc private func textFieldChanged() {

        if isValidValue == false {
            checkValidValue()
        }

        changedValue?(isValidValue, value)

        let isShow = (textViewValue.text?.count ?? 0) > 0

        let isHiddenTitleLabel = !isShow
        guard isHiddenTitleLabel != self.isHiddenTitleLabel else { return }
        self.isHiddenTitleLabel = isHiddenTitleLabel
        titleLabel.isHidden = isHiddenTitleLabel

        if !self.isHiddenTitleLabel {
            self.titleLabel.alpha = 0
        } else {
            self.titleLabel.alpha = 1
        }

        UIView.animate(withDuration: 0.24) {
            if self.isHiddenTitleLabel {
                self.titleLabel.alpha = 0
            } else {
                self.titleLabel.alpha = 1
            }
        }
    }

    private func checkValidValue() {
        checkValidValue(value)
    }

    private func checkValidValue(_ value: String?) {
        var error: String? = nil
        var isValidValue: Bool = false

        if let value = value, value.count > 0 {
            error = valueValidator?(value)
            isValidValue = error == nil
        }

        errorLabel.isHidden = isValidValue
        errorLabel.text = error
        self.isValidValue = isValidValue
    }
}

// MARK: ViewConfiguration
extension InputTextField: ViewConfiguration {
    func update(with model: InputTextField.Model) {
        kind = model.kind
        titleLabel.text = model.title
        placeHolder.text = model.placeholder
        titleLabel.isHidden = isHiddenTitleLabel

        checkValidValue()
        
        switch model.kind {
        case .text:
            isSecureTextEntry = false
            eyeButton.isHidden = true
            textViewValue.autocorrectionType = .no
            textViewValue.autocapitalizationType = .words
            if #available(iOS 10.0, *) {
                textViewValue.textContentType = .name
            }
        case .password, .newPassword:
            if #available(iOS 12.0, *), model.kind == .newPassword {
                textViewValue.textContentType = UITextContentType("")
            } else if #available(iOS 11.0, *), model.kind == .password {
                textViewValue.textContentType = UITextContentType("")
            } else if #available(iOS 10.0, *) {
                textViewValue.textContentType = UITextContentType("")
            }
            isSecureTextEntry = true
            eyeButton.isHidden = false
            textViewValue.autocorrectionType = .no
            textViewValue.autocapitalizationType = .none
        }
    }
}

private extension UITextView {

    func alignTextVerticallyInContainer() {
        guard let font = font else { return }
        let text = (self.text.count == 0 ? "" : self.text) ?? ""
        let height = text.maxHeightMultiline(font: font, forWidth: self.bounds.size.width)
        var topCorrect = (self.bounds.size.height - height) / 2
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        self.textContainerInset.top = topCorrect
    }
}

// MARK: UITextViewDelegate

extension InputTextField: UITextViewDelegate {

    private func updateTextView(_ text: String?) {
        self.originalText = text
        checkValidValue(text)
        let count = text?.count ?? 0
        placeHolder.isHidden = count != 0

        if isSecureTextEntry {
            let secureText = text.enumerated().reduce(into: "") { result, element in
                if element.offset == max(count - 1, 0) {
                    result += String(element.element)
                } else {
                    result += ""
                }
            }
            textViewValue.text = secureText
        } else {
            textViewValue.text = text
        }
//        textViewValue.alignTextVerticallyInContainer()
        textFieldChanged()
        textViewValue.layoutManager.allowsNonContiguousLayout = true
//        textViewValue.textContainerInset = UIEdgeInsetsMake(0, 0, 0, -100)
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        if text == "\n" {
            checkValidValue()
            if isValidValue {
                textFieldShouldReturn?(self)
            }
            return false
        }

        if let originalText = originalText,
            let textRange = Range(range, in: originalText) {
            let updatedText = originalText.replacingCharacters(in: textRange, with: text)

            updateTextView(updatedText)
        } else {
            updateTextView(text)
        }
        return false
    }
}
