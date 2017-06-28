//
//  SelectAccountCollectionCell.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 05/04/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import UIKit

class SelectAccountCollectionCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var balanceIntLabel: UILabel!
    @IBOutlet weak var balanceDecimalLabel: UILabel!
    
    func bindItem(_ item: AssetBalance?) {
        if let ab = item {
            nameLabel.text = ab.issueTransaction?.name
            let bal = MoneyUtil.getScaledPair(ab.balance, Int(ab.issueTransaction?.decimals ?? 0))
            balanceIntLabel.text = bal.0
            balanceDecimalLabel.text = bal.1
        }
    }
}
