//
//  PaymentTransactionCell.swift
//  WavesWallet-iOS
//
//  Created by vvisotskiy on 04.03.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import Extensions
import UIKit

final class PayoutsTransactionCell: UITableViewCell, Reusable {
    
    @IBOutlet private weak var payoutsTransactionView: PayoutsTransactionView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    func configure(_ viewModel: PayoutsHistoryState.UI.PayoutTransactionVM) {
        payoutsTransactionView.setTitle(viewModel.title, details: viewModel.details, transactionValue: viewModel.transactionValue, date: viewModel.dateText)
    }
    
    private func initialSetup() {
        
    }
}

final class PayoutsTransactionView: UIView, NibOwnerLoadable {
    
    @IBOutlet private weak var assetImageView: UIImageView!
    @IBOutlet private weak var titleTransactionLabel: UILabel!
    @IBOutlet private weak var transactionCurrencyContainerView: BalanceLabel!
    @IBOutlet private weak var dateTransactionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        resetToEmptyState()
        initialSetup()
    }
    
    private func initialSetup() {
        do {
            assetImageView.contentMode = .scaleAspectFit
        }
        
        do {}
    }
    
    public func setTitle(_ text: String, details: String, transactionValue: BalanceLabel.Model, date: String) {
        transactionCurrencyContainerView.update(with: transactionValue)
    }
    
    private func resetToEmptyState() {
        assetImageView.image = nil
        titleTransactionLabel.text = nil
        dateTransactionLabel.text = nil
    }
}
