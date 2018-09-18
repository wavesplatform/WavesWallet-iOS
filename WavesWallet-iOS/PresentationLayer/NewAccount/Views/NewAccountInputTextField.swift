//
//  NewAccountInputTextField.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 17.09.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class NewAccountInputTextField: UIView, NibOwnerLoadable {

    enum Kind {
        case password
        case newPassword
        case text
    }

    struct Model {
        let title: String
        let kind: Kind
    }

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var textFieldValue: UITextField!
    @IBOutlet private var eyeButton: UIButton!
    private var secureText: String?

    var value: String? {
        return textFieldValue.text
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

    var valueValidator: ((String?) -> String?)?
    var changedValue: ((Bool,String?) -> Void)?
    var textFieldShouldReturn: ((NewAccountInputTextField) -> Void)?

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
        textFieldValue.delegate = self
        eyeButton.addTarget(self, action: #selector(tapEyeButton), for: .touchUpInside)
        textFieldValue.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }

    @discardableResult override func becomeFirstResponder() -> Bool {
        return textFieldValue.becomeFirstResponder()
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
        let error = valueValidator?(value)
        isValidValue = error == nil
        errorLabel.isHidden = isValidValue
        errorLabel.text = error
    }
}

// MARK: ViewConfiguration
extension NewAccountInputTextField: ViewConfiguration {
    func update(with model: NewAccountInputTextField.Model) {
        kind = model.kind
        titleLabel.text = model.title
        textFieldValue.placeholder = model.title
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
            if #available(iOS 12.0, *), model.kind == .newPassword {
                textFieldValue.textContentType = UITextContentType("")
            } else if #available(iOS 11.0, *), model.kind == .password {
                textFieldValue.textContentType = UITextContentType("")
            } else if #available(iOS 10.0, *) {
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
extension NewAccountInputTextField: UITextFieldDelegate {

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
