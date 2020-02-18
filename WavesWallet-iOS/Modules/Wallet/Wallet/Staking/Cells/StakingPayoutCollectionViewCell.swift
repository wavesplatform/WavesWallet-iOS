//
//  WalletStakingPayoutCollectionViewCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions

private enum Constants {
    static let height: CGFloat = 76
}

final class StakingPayoutCollectionViewCell: UICollectionViewCell, NibReusable {

    @IBOutlet private weak var payoutView: WalletPayoutView!

}

// MARK: ViewConfiguration

extension StakingPayoutCollectionViewCell: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Payout) {
        payoutView.update(with: .init(balance: model.money, date: model.date))
    }
}

// MARK: ViewHeight

extension StakingPayoutCollectionViewCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
