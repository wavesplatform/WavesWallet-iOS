//
//  AddressesKeysAliacesCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AddressesKeysAliacesCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var subTitleLabel: UILabel!
    @IBOutlet private var infoButton: UIButton!
}

//MARK: ViewConfiguration

extension AddressesKeysAliacesCell: ViewConfiguration {

    struct Model {

    }

    func update(with model: AddressesKeysAliacesCell.Model) {

    }
}

//MARK: Localization

extension AddressesKeysAliacesCell: Localization {

    func setupLocalization() {

    }
}
