//
//  AddressesKeysAddressCell.swift
//  
//
//  Created by mefilt on 26/10/2018.
//

import UIKit

final class AddressesKeysValueCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var copyButton: UIButton!
}

//MARK: ViewConfiguration

extension AddressesKeysValueCell: ViewConfiguration {

    struct Model {

    }

    func update(with model: AddressesKeysValueCell.Model) {

    }
}

//MARK: Localization

extension AddressesKeysValueCell: Localization {

    func setupLocalization() {

    }
}
