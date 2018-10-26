//
//  AddressesKeysPrivateKeyCell.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 26/10/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AddressesKeysHiddenPrivateKeyCell: UITableViewCell, Reusable {

    @IBOutlet private var viewContainer: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var showButton: UIButton!
}

//MARK: ViewConfiguration

extension AddressesKeysHiddenPrivateKeyCell: ViewConfiguration {

    struct Model {

    }

    func update(with model: AddressesKeysHiddenPrivateKeyCell.Model) {

    }
}

//MARK: Localization

extension AddressesKeysHiddenPrivateKeyCell: Localization {

    func setupLocalization() {

    }
}
