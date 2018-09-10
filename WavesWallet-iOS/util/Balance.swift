//
//  Balance.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Balance {
    struct Currency {
        let title: String
        let ticker: String?
    }

    let currency: Currency
    let money: Money
}

extension Balance {

    var displayText: String {
        return money.displayTextFull + " " + currency.title
    }

    var displayTextWithoutCurrencyName: String {
        return money.displayTextFull
    }
}
