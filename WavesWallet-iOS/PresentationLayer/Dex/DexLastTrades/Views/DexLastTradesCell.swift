//
//  DexLastTradesCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/22/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexLastTradesCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelTime: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelSum: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

extension DexLastTradesCell: ViewConfiguration {
    
    func update(with model: DexLastTrades.DTO.Trade) {

        labelTime.text = DexLastTrades.ViewModel.dateFormatter.string(from: model.time)
        labelPrice.text = model.price.displayText
        
        labelAmount.text = model.amount.displayText
        
        labelSum.text = model.sum.displayText
        
        labelPrice.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
    }
}
