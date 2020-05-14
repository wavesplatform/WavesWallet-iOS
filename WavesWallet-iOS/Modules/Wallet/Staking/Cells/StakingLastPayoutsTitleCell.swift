//
//  WalletStakingLastPyoutsTitleCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit
import UITools

final class StakingLastPayoutsTitleCell: UITableViewCell, NibReusable {
    @IBOutlet private weak var labelTitle: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        labelTitle.text = Localizable.Waves.Wallet.Stakingpayouts.lastPayouts
    }
}
