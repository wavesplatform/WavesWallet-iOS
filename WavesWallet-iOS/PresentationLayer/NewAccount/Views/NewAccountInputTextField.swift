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

    var value: String? {
        return textFieldValue.text
    }

    private var isHiddenTitleLabel: Bool = true
    private var isSecureTextEntry: Bool = false {
        didSet {
            textFieldValue.isSecureTextEntry = isSecureTextEntry
            if isSecureTextEntry {
                eyeButton.setImage(Images.eyeopen24Basic500.image, for: .normal)
            } else {
                eyeButton.setImage(Images.eyeclsoe24Basic500.image, for: .normal)
            }
        }
    }

    var valueValidator: ((String?) -> String?)?
    var changedValue: ((Bool,String?) -> Void)?
    private(set) var isValidValue: Bool = false

    private var kind: Kind?

    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
        eyeButton.addTarget(self, action: #selector(tapEyeButton), for: .touchUpInside)
        textFieldValue.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textFieldValue.addTarget(self, action: #selector(textFieldEndChanged), for: .editingDidEnd)
    }

    @objc private func tapEyeButton() {
        isSecureTextEntry = !isSecureTextEntry
    }

    @objc private func textFieldEndChanged() {
        checkValidValue()
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
        let error = valueValidator?(value)
        isValidValue = error == nil
        errorLabel.isHidden = isValidValue
        errorLabel.text = error
    }
}

extension NewAccountInputTextField: ViewConfiguration {
    func update(with model: NewAccountInputTextField.Model) {
        kind = model.kind
        titleLabel.text = model.title
        textFieldValue.placeholder = model.title
        titleLabel.isHidden = isHiddenTitleLabel

        checkValidValue()
        switch model.kind {
        case .text:
            if #available(iOS 10.0, *) {
                textFieldValue.textContentType = .name
            }
            eyeButton.isHidden = true
            isSecureTextEntry = false
        case .password, .newPassword:
            if #available(iOS 11.0, *) {
                if model.kind == .password {
                    textFieldValue.textContentType = .password
                } else {
                    textFieldValue.textContentType = UITextContentType.
                }
            } 
            eyeButton.isHidden = false
            isSecureTextEntry = true
        }
    }
}
