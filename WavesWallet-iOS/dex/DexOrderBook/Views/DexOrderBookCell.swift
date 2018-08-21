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
        
        labelAmount.text = model.amount.displayText

        labelSum.text = MoneyUtil.getScaledText(model.sum.amount, decimals: model.sum.decimals, maximumFractionDigits: model.defaultScaleDecimal)
    
        percentAmountOverlay = CGFloat(model.percentAmount)
    }
}

private extension MoneyUtil {
    class func getScaledText(_ amount: Int64, decimals: Int,  maximumFractionDigits: Int, scale: Int? = nil) -> String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = maximumFractionDigits
        f.minimumFractionDigits = decimals
        let result = f.string(from: Decimal(amount) / pow(10, scale ?? decimals) as NSNumber)
        return result ?? ""
    }
}
