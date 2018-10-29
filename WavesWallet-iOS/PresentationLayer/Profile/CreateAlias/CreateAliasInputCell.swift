//
//  CreateAliasInputCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 29/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let height: CGFloat = 60
}

final class CreateAliasInputCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var inputTextField: InputTextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
        setupTextField()
    }

    private func setupTextField() {

        inputTextField.autocapitalizationType = .none

        inputTextField.update(with: InputTextField.Model(title: "Symbolic name",
                                                           kind: .text,
                                                           placeholder: "Symbolic name"))

        inputTextField.returnKey = .done

        inputTextField.textFieldShouldReturn = { [weak self] _ in
//            self?.passwordInput.becomeFirstResponder()
        }


        inputTextField.valueValidator = { text -> String? in
            return nil
        }

        inputTextField.changedValue = { [weak self] isValidData, text in

        }
    }

//    private func continueChangePassword() {
//
//    }
//
//    @IBAction func handlerConfirmButton() {
//        continueChangePassword()
//    }
}

// MARK: ViewConfiguration

extension CreateAliasInputCell: ViewConfiguration {

    struct Model {
        let text: String
    }

    func update(with model: CreateAliasInputCell.Model) {
        inputTextField.value = model.text
    }
}

// MARK: ViewCalculateHeight

extension CreateAliasInputCell: ViewCalculateHeight {

    static func viewHeight(model: Model, width: CGFloat) -> CGFloat {
        return Constants.height
    }
}


// MARK: Localization

extension CreateAliasInputCell: Localization {

    func setupLocalization() {
//        self.titleLabel.text = "Aliases"
    }
}
