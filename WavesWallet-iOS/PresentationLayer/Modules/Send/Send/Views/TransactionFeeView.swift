//
//  TransactionFeeView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 1/19/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import UIKit

private enum Constants {
    static let smallRightOffset: CGFloat = 14
    static let bigRightOffset: CGFloat = 38
}

protocol TransactionFeeViewDelegate: AnyObject {
    
    func transactionFeeViewDidTap()
}

final class TransactionFeeView: UIView, NibOwnerLoadable {

    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var labelLocalization: UILabel!
    @IBOutlet private weak var labelFee: UILabel!
    @IBOutlet private weak var labelTicker: UILabel!
    @IBOutlet private weak var iconArrows: UIImageView!
    @IBOutlet private weak var rightTickerPadding: NSLayoutConstraint!
    
    weak var delegate: TransactionFeeViewDelegate?
    
    var isSelectedAssetFee = false {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        loadNibContent()
        labelLocalization.text = Localizable.Waves.Transactionfee.Label.transactionFee
        updateUI()
    }
    
    @IBAction private func buttontTapped(_ sender: Any) {
        delegate?.transactionFeeViewDidTap()
    }
    
    private func updateUI() {
        
        if isSelectedAssetFee {
            rightTickerPadding.constant = Constants.bigRightOffset
            iconArrows.isHidden = false
        }
        else {
            rightTickerPadding.constant = Constants.smallRightOffset
            iconArrows.isHidden = true
        }
    }
    
    func showLoadingState() {
        isHidden = false
        labelFee.isHidden = true
        labelTicker.isHidden = true
        iconArrows.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideLoadingState() {
        labelTicker.isHidden = false
        labelFee.isHidden = false
        iconArrows.isHidden = !isSelectedAssetFee
        activityIndicator.stopAnimating()
    }
}

extension TransactionFeeView: ViewConfiguration {
    
    func update(with model: Money) {
        labelFee.text = model.displayText
    }
}
