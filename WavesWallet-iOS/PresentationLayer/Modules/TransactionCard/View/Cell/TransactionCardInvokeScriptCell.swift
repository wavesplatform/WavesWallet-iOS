//
//  TransactionCardInvokeScriptCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/11/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let paymentBottomOffset: CGFloat = 14
}

final class TransactionCardInvokeScriptCell: UITableViewCell, Reusable {

    @IBOutlet private weak var labelScriptAddressLocalizable: UILabel!
    @IBOutlet private weak var labelScriptAddress: UILabel!
    @IBOutlet private weak var buttonCopy: PasteboardButton!
    @IBOutlet private weak var viewPayment: UIView!
    @IBOutlet private weak var labelPaymentLocalization: UILabel!
    @IBOutlet private weak var paymentBottomOffset: NSLayoutConstraint!
    @IBOutlet private weak var labelPayment: BalanceLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonCopy.isBlack = true
        buttonCopy.copiedText = { [weak self] in
            guard let self = self else { return nil }
            return self.labelScriptAddress.text
        }
        labelScriptAddressLocalizable.text = Localizable.Waves.Transactioncard.Title.scriptAddress
        labelPaymentLocalization.text = Localizable.Waves.Transactioncard.Title.payment
    }
}

extension TransactionCardInvokeScriptCell: ViewConfiguration {
    
    func update(with model: DomainLayer.DTO.SmartTransaction.InvokeScript) {
        
        labelScriptAddress.text = model.scriptAddress
        viewPayment.isHidden = model.payment == nil
        paymentBottomOffset.constant = model.payment == nil ? 0 : Constants.paymentBottomOffset
        
        guard let payment = model.payment else { return }
        
        let assetName = model.payment?.asset?.displayName ?? ""
        let ticker = model.payment?.asset == nil ? GlobalConstants.wavesAssetId : nil
        
        let balance = Balance(currency: Balance.Currency(title: assetName, ticker: ticker), money: payment.amount)
        let style = BalanceLabel.Model(balance: balance,
                                       sign: nil,
                                       style: .small)
        labelPayment.update(with: style)
    }
}
