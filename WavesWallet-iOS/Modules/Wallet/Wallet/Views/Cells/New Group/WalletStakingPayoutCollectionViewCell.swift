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

final class WalletStakingPayoutCollectionViewCell: UICollectionViewCell, NibReusable {

    @IBOutlet private weak var payoutView: WalletPayoutView!

}

extension WalletStakingPayoutCollectionViewCell: ViewConfiguration {
    
    func update(with model: WalletTypes.DTO.Staking.Payout) {
        payoutView.update(with: .init(balance: model.money, date: model.date))
    }
}

extension WalletStakingPayoutCollectionViewCell: ViewHeight {
    static func viewHeight() -> CGFloat {
        return Constants.height
    }
}
