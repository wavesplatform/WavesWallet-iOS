//
//  AssetBalanceMoneyInfoView.swift
//  WavesWallet-iOS
//
//  Created by mefilt on 20.08.2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class AssetBalanceMoneyInfoView: UIView, NibOwnerLoadable, ViewConfiguration {

    struct Model {
        let name: String
        let money: Money
        let isFiat: Bool
    }

    @IBOutlet private var namelabel: UILabel!
    @IBOutlet private var balanceLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }

    func update(with model: Model) {
        namelabel.text = model.name
        balanceLabel.attributedText = NSAttributedString.styleForBalance(text: model.money.displayTextFull(isFiat: model.isFiat), font: balanceLabel.font)
    }
}
