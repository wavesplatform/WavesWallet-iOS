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

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var textFieldValue: UITextField!
    @IBOutlet private var eyeButton: UIButton!

    private lazy var tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                                 action: #selector(handlerTapGesture(recognizer:)))
    private var secureText: String?

    var value: String? {
        set {
            textFieldValue.text = newValue
            checkValidValue()
        }

        get {
            return textFieldValue.text
        }
    }

    private var isHiddenTitleLabel: Bool = true
    private var isSecureTextEntry: Bool = false {
        didSet {
            textFieldValue.isSecureTextEntry = isSecureTextEntry
            if #available(iOS 10.0, *) {
                textFieldValue.textContentType = UITextContentType("")
            }
            if isSecureTextEntry {
                eyeButton.setImage(Images.eyeopen24Basic500.image, for: .normal)
            } else {
                eyeButton.setImage(Images.eyeclsoe24Basic500.image, for: .normal)
            }
        }
    }

    private var externalError: String?

    var valueValidator: ((String?) -> String?)?
    var changedValue: ((Bool,String?) -> Void)?
    var textFieldShouldReturn: ((InputTextField) -> Void)?

    var returnKey: UIReturnKeyType? {
        didSet {
            textFieldValue.returnKeyType = returnKey ?? .done
        }
    }

    private(set) var isValidValue: Bool = false

    private var kind: Kind?

    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
        addGestureRecognizer(tapGesture)
        textFieldValue.delegate = self
        eyeButton.addTarget(self, action: #selector(tapEyeButton), for: .touchUpInside)
        textFieldValue.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        return textFieldValue.becomeFirstResponder()
    }

    @objc private func handlerTapGesture(recognizer: UITapGestureRecognizer) {
        becomeFirstResponder()
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

        let isShow = (textFieldValue.text?.count ?? 0) > 0

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
        var isValidValue: Bool = true

        if let value = value, value.count > 0, let validator = valueValidator {
            error = validator(value)
            isValidValue = error == nil
        } else if let externalError = externalError {
            error = externalError
            isValidValue = false
        } else {
            isValidValue = (value?.count ?? 0) > 0
        }

        errorLabel.isHidden = isValidValue
        errorLabel.text = error
        self.isValidValue = isValidValue
    }

    func setError(_ error: String?) {
        externalError = error
        checkValidValue()
    }
}

// MARK: ViewConfiguration
extension InputTextField: ViewConfiguration {
    func update(with model: InputTextField.Model) {
        kind = model.kind
        titleLabel.text = model.title
        textFieldValue.placeholder = model.placeholder
        titleLabel.isHidden = isHiddenTitleLabel

        checkValidValue()
        
        switch model.kind {
        case .text:
            isSecureTextEntry = false
            eyeButton.isHidden = true
            textFieldValue.autocorrectionType = .no
            textFieldValue.autocapitalizationType = .words
            if #available(iOS 10.0, *) {
                textFieldValue.textContentType = .name
            }
        case .password, .newPassword:
            if #available(iOS 10.0, *) {
                textFieldValue.textContentType = UITextContentType("")
            }
            isSecureTextEntry = true
            eyeButton.isHidden = false
            textFieldValue.autocorrectionType = .no
            textFieldValue.autocapitalizationType = .none
        }
    }
}

// MARK: UITextFieldDelegate
extension InputTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        checkValidValue()
        if isValidValue {
            textFieldShouldReturn?(self)
            return true
        }

        return false
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if let text = textField.text,
            let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
            checkValidValue(updatedText)
        }
        return true
    }
}
