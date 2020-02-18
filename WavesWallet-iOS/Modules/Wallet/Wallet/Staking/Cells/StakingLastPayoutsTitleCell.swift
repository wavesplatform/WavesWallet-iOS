//
//  WalletStakingLastPyoutsTitleCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 46
}

final class StakingLastPayoutsTitleCell: UITableViewCell, NibReusable {

    @IBOutlet private weak var labelTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}

extension StakingLastPayoutsTitleCell: ViewConfiguration {
    
    func update(with model: Void) {
        labelTitle.text = Localizable.Waves.Wallet.Stakingpayouts.lastPayouts
    }
}

extension StakingLastPayoutsTitleCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
