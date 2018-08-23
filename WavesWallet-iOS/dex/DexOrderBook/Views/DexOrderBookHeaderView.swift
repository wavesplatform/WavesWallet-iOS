//
//  DexOrderBookHeaderView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexOrderBookHeaderView: DexTraderContainerBaseHeaderView, NibOwnerLoadable {
    
    @IBOutlet private weak var labelAmountAssetName: UILabel!
    @IBOutlet private weak var labelPriceAssetName: UILabel!
    @IBOutlet private weak var labelSumAssetName: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibContent()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibContent()
    }
}

//MARK: - SetupUI

extension DexOrderBookHeaderView: ViewConfiguration {
    
    func update(with model: DexOrderBook.ViewModel.Header) {
        labelAmountAssetName.text = Localizable.DexOrderBook.Label.amount + " " + model.amountName
        labelPriceAssetName.text = Localizable.DexOrderBook.Label.price + " " + model.priceName
        labelSumAssetName.text = Localizable.DexOrderBook.Label.sum + " " + model.sumName
    }
}
