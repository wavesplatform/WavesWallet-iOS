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
        
        labelPrice.text = MoneyUtil.getScaledText(model.price.amount, decimals: model.price.decimals, scale: model.defaultScaleDecimal + model.price.decimals - model.amount.decimals)
        
        labelAmount.text = model.amount.displayText
        
        // Need check correct of calculation if decimals of price and amount will be different
        let sum = model.price.amount * model.amount.amount /// NSDecimalNumber(decimal: pow(10, model.price.decimals)).int64Value
        labelSum.text = MoneyUtil.getScaledText(sum, decimals: model.price.decimals)
    
        percentAmountOverlay = 50
    }
}
