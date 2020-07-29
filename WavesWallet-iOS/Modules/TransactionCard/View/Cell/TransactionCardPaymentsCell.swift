//
//  TransactionCardInvokeScriptCell.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 4/11/19.
//  Copyright © 2019 Waves Exchange. All rights reserved.
//

import DomainLayer
import Extensions
import UIKit
import UITools
import WavesSDK
import WavesSDKExtensions

private struct Constants {
    static let paddingBetweenElement: CGFloat = 8
    static let paddingTopOrDown: CGFloat = 12
}

final class TransactionCardPaymentsCell: UITableViewCell, Reusable {
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.backgroundColor = .basic50
        stackView.spacing = Constants.paddingBetweenElement
        titleLabel.text = Localizable.Waves.Transactioncard.Title.payment
    }

    func setPayments(_ payments: [SmartTransaction.InvokeScript.Payment]) {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }

        let views = payments.map { payment -> TransactionCardPaymentView in
            let view: TransactionCardPaymentView = TransactionCardPaymentView.loadView()
            view.backgroundColor = .basic50
            view.setTitle(payment.asset.displayName)
            view.setBalance(payment.amount)
            view.setAssetIcon(payment.asset.iconLogo)

            return view
        }

        let topView = UIView()
        topView.backgroundColor = .basic50
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.heightAnchor.constraint(equalToConstant: Constants.paddingTopOrDown).isActive = true
        stackView.addArrangedSubview(topView)

        stackView.addArrangedSubviews(views)

        let bottomView = UIView()
        bottomView.heightAnchor.constraint(equalToConstant: Constants.paddingTopOrDown).isActive = true
        bottomView.backgroundColor = .basic50
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(bottomView)
    }
}
