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
        let contact: DomainLayer.DTO.Contact
        let isEditMode: Bool
    }
    
    func update(with model: Input) {
        labelName.text = model.contact.name
        labelAddress.text = model.contact.address
        buttonEdit.isHidden = !model.isEditMode
        iconCheckmark.isHidden = model.isEditMode
    }
}
