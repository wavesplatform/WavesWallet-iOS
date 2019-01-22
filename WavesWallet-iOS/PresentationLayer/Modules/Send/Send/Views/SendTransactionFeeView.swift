//
//  SendTransactionFeeView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/19/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

final class SendTransactionFeeView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var labelLocalization: UILabel!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var labelTicker: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
        labelLocalization.text = Localizable.Waves.Send.Label.transactionFee
    }
    
    func showLoadingState() {
        isHidden = false
        labelFee.isHidden = true
        labelTicker.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingState() {
        labelTicker.isHidden = false
        labelFee.isHidden = false
        activityIndicator.stopAnimating()
    }
}

extension SendTransactionFeeView: ViewConfiguration {
    
    func update(with model: Money) {
        labelFee.text = model.displayText
    }
}
