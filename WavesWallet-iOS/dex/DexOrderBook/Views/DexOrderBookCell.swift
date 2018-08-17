//
//  DexOrderBookCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexOrderBookCell: UITableViewCell, Reusable {

    @IBOutlet weak var labelAmount: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var labelSum: UILabel!
    @IBOutlet weak var backgroundAmountView: UIView!
    @IBOutlet weak var backgroundAmountViewWidth: NSLayoutConstraint!
    
    private var percentAmountOverlay: CGFloat = 0
  
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundAmountViewWidth.constant = frame.size.width * percentAmountOverlay / 100
    }
}

extension DexOrderBookCell: ViewConfiguration {
   
    func update(with model: DexOrderBook.DTO.BidAsk) {
        
        labelPrice.textColor = model.orderType == .sell ? UIColor.submit400 : UIColor.error500
        backgroundAmountView.backgroundColor = model.orderType == .sell ? UIColor.submit50 : UIColor.error100
        
        labelPrice.text = MoneyUtil.getScaledText(model.price, decimals: model.priceAssetDecimal, scale: model.defaultScaleDecimal + model.priceAssetDecimal - model.amountAssetDecimal)
        
        labelAmount.text = MoneyUtil.getScaledTextTrimZeros(model.amount, decimals: model.amountAssetDecimal)
        labelSum.text = "341414.323"
    
        percentAmountOverlay = 50
    }
}
