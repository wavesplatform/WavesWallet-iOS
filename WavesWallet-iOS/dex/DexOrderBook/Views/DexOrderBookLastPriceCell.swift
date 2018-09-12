//
//  DexOrderBookLastPriceCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexOrderBookLastPriceCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelSpread: UILabel!
    @IBOutlet private weak var iconState: UIImageView!
    @IBOutlet private weak var labelLastPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelLastPrice.text = Localizable.DexOrderBook.Label.lastPrice
    }
}

extension DexOrderBookLastPriceCell: ViewConfiguration {
   
    func update(with model: DexOrderBook.DTO.LastPrice) {
        
        labelPrice.text = model.price.formattedText()
       
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
