//
//  MigrateAccountsTopCell.swift
//  WavesWallet-iOS
//
//  Created by Лера on 10/2/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

final class MigrateAccountsTopCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelTitle: UILabel!
    @IBOutlet private weak var labelSubtitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = Localizable.Waves.Migrationaccounts.Label.migrateAccounts
        labelSubtitle.text = Localizable.Waves.Migrationaccounts.Label.description
    }

}
