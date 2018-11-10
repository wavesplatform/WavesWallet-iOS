//
//  DexMyOrdersCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 8/24/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import UIKit

final class DexMyOrdersCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelTimeText: UILabel!
    @IBOutlet private weak var labelTime: UILabel!
    @IBOutlet private weak var labelStatusText: UILabel!
    @IBOutlet private weak var labelStatus: UILabel!
    @IBOutlet private weak var labelPriceText: UILabel!
    @IBOutlet private weak var labelPrice: UILabel!
    @IBOutlet private weak var labelAmountText: UILabel!
    @IBOutlet private weak var labelAmount: UILabel!
    
    var buttonDeleteDidTap: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLocalization()
    }
}

extension DexMyOrdersCell: ViewConfiguration {
    
    func update(with model: DexMyOrders.DTO.Order) {
        
        labelTime.text = DexMyOrders.ViewModel.dateFormatterTime.string(from: model.time)
        labelStatus.text = model.statusText
        labelAmount.text = model.amount.formattedText()
        labelPrice.text = model.price.formattedText()
        labelStatus.textColor = model.type == .sell ? UIColor.error500 : UIColor.submit400
    }
    
}

//MARK: - Actions
private extension DexMyOrdersCell {
   
    @IBAction func deleteTapped(_ sender: Any) {
        buttonDeleteDidTap?()
    }
}

//MARK: - SetupUI
private extension DexMyOrdersCell {
        
    func setupLocalization() {
        labelTimeText.text = Localizable.Waves.Dexmyorders.Label.time
        labelStatusText.text = Localizable.Waves.Dexmyorders.Label.status
        labelAmountText.text = Localizable.Waves.Dexmyorders.Label.amount
        labelPriceText.text = Localizable.Waves.Dexmyorders.Label.price
    }
}

//MARK: - DexMyOrders.DTO.Order
fileprivate extension DexMyOrders.DTO.Order {
    
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
