//
//  DexOrderBookCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/16/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexOrderBookCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelSum: UILabel!
    @IBOutlet private weak var backgroundAmountView: UIView!
    @IBOutlet private weak var backgroundAmountViewWidth: NSLayoutConstraint!
    
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
        
        labelPrice.text = model.price.displayText
        
        labelAmount.text = model.amount.displayText
        
        labelSum.text = model.sum.displayText
    
        percentAmountOverlay = CGFloat(model.percentAmount)
    }
}

