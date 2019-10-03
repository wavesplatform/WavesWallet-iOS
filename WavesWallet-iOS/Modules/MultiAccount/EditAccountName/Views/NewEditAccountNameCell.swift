//
//  NewEditAccountNameCell.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/3/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

protocol NewEditAccountNameCellDelegate: AnyObject {

    func newEditAccountNameDidChangeName(newName: String)
    func newEditAccountNameDidTapSave()
}

final class NewEditAccountNameCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelOldName: UILabel!
    @IBOutlet private weak var labelNewName: UILabel!
    @IBOutlet private weak var imageViewIcon: UIImageView!
    @IBOutlet private weak var textField: InputTextField!
   
    private let keyboardView = EditAccountKeyboardControl.loadFromNib()
   
    weak var delegate: NewEditAccountNameCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelNewName.text = Localizable.Waves.Neweditaccountname.Label.newName
        setupTextField()
        
        keyboardView.dismissAction = { [weak self] in
            guard let self = self else { return }
            self.textField.dismiss()
        }
        textField.keyboardInputAccessoryView = keyboardView
        
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            self.textField.becomeFirstResponder()
        }
    }
   
    @IBAction private func saveTapped(_ sender: Any) {
        delegate?.newEditAccountNameDidTapSave()
    }
    
    private func setupTextField() {
        textField.autocapitalizationType = .words

        textField.valueValidator = { value in
            let trimmedValue = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            if trimmedValue.count < UIGlobalConstants.accountNameMinLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.atleastcharacters(UIGlobalConstants.accountNameMinLimitSymbols)
            } else if trimmedValue.count > UIGlobalConstants.accountNameMaxLimitSymbols {
                return Localizable.Waves.Newaccount.Textfield.Error.charactersmaximum(UIGlobalConstants.accountNameMaxLimitSymbols)
            } else {
                return nil
            }
        }
        
        textField.changedValue = { (isValidValue, value) in
            self.keyboardView.isActive = isValidValue
            self.delegate?.newEditAccountNameDidChangeName(newName: value ?? "")
        }
        
        textField.returnKey = .done
    }
}

extension NewEditAccountNameCell: ViewConfiguration {
    
    struct Model {
        let oldName: String
        let newName: String
        let icon: UIImage?
    }
    
    func update(with model: NewEditAccountNameCell.Model) {
        labelOldName.text = model.oldName
        textField.value = model.newName
        imageViewIcon.image = model.icon
        
        textField.update(with: InputTextField.Model(title: model.newName,
                                                    kind: .text,
                                                    placeholder: Localizable.Waves.Neweditaccountname.Label.newName))

    }
}
