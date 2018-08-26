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
        
        labelTime.text = DexMyOrders.ViewModel.dateFormatter.string(from: model.time)
        labelStatus.text = model.status
        labelAmount.text = model.amount.formattedText(defaultMinimumFractionDigits: false)
        labelPrice.text = model.price.formattedText(defaultMinimumFractionDigits: false)
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
        labelTimeText.text = Localizable.DexMyOrders.Label.time
        labelStatusText.text = Localizable.DexMyOrders.Label.status
        labelAmountText.text = Localizable.DexMyOrders.Label.amount
        labelPriceText.text = Localizable.DexMyOrders.Label.price
    }
}
