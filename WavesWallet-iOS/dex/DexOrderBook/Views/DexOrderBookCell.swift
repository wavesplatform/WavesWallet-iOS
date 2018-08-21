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
    
    private let minFullPercent: CGFloat = 90
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backgroundAmountViewWidth.constant = frame.size.width * percentAmountOverlay / minFullPercent
    }
}

extension DexOrderBookCell: ViewConfiguration {
   
    func update(with model: DexOrderBook.DTO.BidAsk) {
        
        labelPrice.textColor = model.orderType == .sell ? UIColor.submit400 : UIColor.error500
        backgroundAmountView.backgroundColor = model.orderType == .sell ? UIColor.submit50 : UIColor.error100
        
        labelPrice.text = model.priceText
        
        labelAmount.text = MoneyUtil.getScaledText(model.amount.amount, decimals: model.amount.decimals, defaultMaximumFractionDigits: true, defaultMinimumFractionDigits: false)

        labelSum.text = MoneyUtil.getScaledText(model.sum.amount, decimals: model.sum.decimals, defaultMaximumFractionDigits: true, defaultMinimumFractionDigits: false)
    
        percentAmountOverlay = CGFloat(model.percentAmount)
    }
}

