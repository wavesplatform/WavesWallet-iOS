//
//  WalletPayoutView.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 11.02.2020.
//  Copyright © 2020 Waves Platform. All rights reserved.
//

import UIKit
import Extensions
import SwiftDate

private enum Constants {
    static let dateFormatterKey: String = "WalletPayoutView.dateFormatterKey"
}

final class WalletPayoutView: UIView, NibLoadable {

    @IBOutlet private weak var labelProfit: UILabel!
    @IBOutlet private weak var labelProfitValue: UILabel!
    @IBOutlet private weak var labelDate: UILabel!
    @IBOutlet private weak var labelTime: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTableCellShadowStyle()
    }
}

extension WalletPayoutView: ViewConfiguration {
    
    struct Model {
        let balance: Money
        let date: Date
    }
    
    func update(with model: Model) {
    
        labelProfit.text = Localizable.Waves.Wallet.Stakingpayouts.profit
        labelProfitValue.text = model.balance.displayText

        let locale = Locales(rawValue: Language.currentLanguage.code)?.toLocale() ?? Locales.english.toLocale()

        let dateFormatter = DateFormatter.uiSharedFormatter(key: Constants.dateFormatterKey)
        let dateFormat: String

        if model.date.compare(.isThisMonth) {
            dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMM", options: 0, locale: locale) ?? "MMM dd"
        }
        else {
            dateFormat = DateFormatter.dateFormat(fromTemplate: "ddMMMyyyy", options: 0, locale: locale) ?? "MMM dd, yyyy"
        }

        dateFormatter.dateFormat = dateFormat
        labelDate.text = dateFormatter.string(from: model.date)

        dateFormatter.dateFormat = "HH:mm"
        labelTime.text = dateFormatter.string(from: model.date)
    }
}
