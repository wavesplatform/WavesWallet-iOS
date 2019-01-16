//
//  DexMyOrdersCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexMyOrdersCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelTime: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var labelSide: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    @IBOutlet private weak var labelSum: UILabel!
    @IBOutlet private weak var labelFilled: UILabel!
    @IBOutlet private weak var buttonDelete: UIButton!
    @IBOutlet private weak var viewSeparate: UIView!
    
    var buttonDeleteDidTap: (() -> Void)?
}

extension DexMyOrdersCell: ViewConfiguration {
    
    func update(with model: DomainLayer.DTO.Dex.MyOrder) {
        
        labelDate.text = DexMyOrders.ViewModel.dateFormatterDate.string(from: model.time)
        labelTime.text = DexMyOrders.ViewModel.dateFormatterTime.string(from: model.time)
        labelStatus.text = model.statusText
        labelAmount.text = model.amount.displayText
        labelPrice.text = model.price.displayText
        labelSide.text = model.type == .sell ? Localizable.Waves.Dexmyorders.Label.sell : Localizable.Waves.Dexmyorders.Label.buy
        labelSide.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
        labelPrice.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
        labelFilled.text = model.filled.displayText

        let sum = Money(value: model.price.decimalValue * model.amount.decimalValue, model.price.decimals)
        labelSum.text = sum.displayText
        
        buttonDelete.isHidden = model.status == .filled || model.status == .cancelled
        viewSeparate.isHidden = buttonDelete.isHidden
    }
    
}

//MARK: - Actions
private extension DexMyOrdersCell {
   
    @IBAction func deleteTapped(_ sender: Any) {
        buttonDeleteDidTap?()
    }
}

//MARK: - DomainLayer.DTO.Dex.MyOrder
fileprivate extension DomainLayer.DTO.Dex.MyOrder {
    
    var statusText: String {
        switch status {
        case .accepted:
            return Localizable.Waves.Dexmyorders.Label.Status.accepted
            
        case .partiallyFilled:
            return Localizable.Waves.Dexmyorders.Label.Status.partiallyFilled
            
        case .cancelled:
            return Localizable.Waves.Dexmyorders.Label.Status.cancelled
            
        case .filled:
            return Localizable.Waves.Dexmyorders.Label.Status.filled
        }
    }
}
