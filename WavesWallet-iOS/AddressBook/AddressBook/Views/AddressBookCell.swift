//
//  AddressBookCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

protocol AddressBookCellDelegate: AnyObject {
    func addressBookCellDidTapEdit(_ cell: AddressBookCell)
}

final class AddressBookCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelName: UILabel!
    @IBOutlet private weak var labelAddress: UILabel!
    @IBOutlet private weak var buttonEdit: UIButton!
    @IBOutlet private weak var iconCheckmark: UIImageView!
    
    weak var delegate: AddressBookCellDelegate?
    
    @IBAction private func buttonTapped(_ sender: Any) {
        delegate?.addressBookCellDidTapEdit(self)
    }
}

extension AddressBookCell: ViewConfiguration {
    
    struct Input {
        let user: AddressBook.DTO.User
        let isEditMode: Bool
    }
    
    func update(with model: Input) {
        labelName.text = model.user.name
        labelAddress.text = model.user.address
        buttonEdit.isHidden = !model.isEditMode
        iconCheckmark.isHidden = model.isEditMode
    }
}
