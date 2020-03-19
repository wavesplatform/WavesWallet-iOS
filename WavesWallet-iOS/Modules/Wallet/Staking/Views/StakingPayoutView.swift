//
//  WalletPayoutView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import DomainLayer

private enum Constants {
    static let dateFormatterKey: String = "WalletPayoutView.dateFormatterKey"
}

final class StakingPayoutView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var labelProfit: UILabel!
    @IBOutlet private weak var labelDate: UILabel!    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var balanceLabel: BalanceLabel!
        
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadNibContent()
    }
}

// MARK: ViewConfiguration

extension StakingPayoutView: ViewConfiguration {
    
    struct Model {
        let profit: DomainLayer.DTO.Balance
        let assetIconURL: DomainLayer.DTO.Asset.Icon
        let date: Date
    }
    
    func update(with model: Model) {
        
        self.balanceLabel.update(with: .init(balance: model.profit  ,
                                             sign: nil,
                                             style: .medium))

        let dateFormatter = DateFormatter.uiSharedFormatter(key: Constants.dateFormatterKey)
                                                            
        dateFormatter.setStyle(.pretty(model.date))
        labelDate.text = dateFormatter.string(from: model.date)
    }
}
