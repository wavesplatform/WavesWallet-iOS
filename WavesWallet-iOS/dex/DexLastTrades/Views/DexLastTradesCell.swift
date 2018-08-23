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
    
    private static let dateFormatter = DateFormatter()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DexLastTradesCell.dateFormatter.dateFormat = "HH:mm:ss"
    }
}

extension DexLastTradesCell: ViewConfiguration {
    
    func update(with model: DexLastTrades.DTO.Trade) {

        labelTime.text = DexLastTradesCell.dateFormatter.string(from: model.time)
        labelPrice.text = MoneyUtil.getScaledText(model.price.amount, decimals: model.price.decimals, defaultMaximumFractionDigits: true, defaultMinimumFractionDigits: false)
        labelAmount.text = MoneyUtil.getScaledText(model.amount.amount, decimals: model.amount.decimals, defaultMaximumFractionDigits: true, defaultMinimumFractionDigits: false)
        labelSum.text = MoneyUtil.getScaledText(model.sum.amount, decimals: model.sum.decimals, defaultMaximumFractionDigits: true, defaultMinimumFractionDigits: false)
        
        labelPrice.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
    }
}
