//
//  DexOrderBookLastPriceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexOrderBookLastPriceCell: UITableViewCell, Reusable {

    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelSpread: UILabel!
    @IBOutlet weak var iconState: UIImageView!
    @IBOutlet weak var labelLastPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelLastPrice.text = Localizable.DexOrderBook.Label.lastPrice
    }
}

extension DexOrderBookLastPriceCell: ViewConfiguration {
   
    func update(with model: DexOrderBook.DTO.LastPrice) {
        
        labelPrice.text = MoneyUtil.getScaledText(model.price.amount, decimals: model.price.decimals, defaultMaximumFractionDigits: true, defaultMinimumFractionDigits: false)
       
        if model.percent > 0 {
            labelSpread.text = Localizable.DexOrderBook.Label.spread + " " + String(format: "%.02f", model.percent) + "%"
        }
        else {
            labelSpread.text = Localizable.DexOrderBook.Label.spread + " " + "%"
        }
        
        if model.orderType == .sell {
            iconState.image = Images.chartarrow22Error500.image
        }
        else if model.orderType == .buy {
            iconState.image = Images.chartarrow22Success400.image
        }
        else if model.orderType == .none {
            iconState.image = nil
        }
    }
}
