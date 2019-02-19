//
//  Balance.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

struct Balance: Equatable {
    struct Currency: Equatable {
        let title: String
        let ticker: String?
    }

    let currency: Currency
    let money: Money
}

extension Balance {

    enum Sign: String, Equatable {
        case none = ""
        case plus = "+"
        case minus = "-"
    }

    func displayShortText(sign: Sign, withoutCurrency: Bool) -> String {
        var text = ""
        
        if withoutCurrency {
            text = money.displayShortText
        } else {
            text = money.displayShortText + " " + currency.title
        }
        
        return sign.rawValue + text
    }
    
    func displayText(sign: Sign, withoutCurrency: Bool) -> String {
        var text = ""

        if withoutCurrency {
            text = money.displayText
        } else {
            text = money.displayText + " " + currency.title
        }

        return sign.rawValue + text
    }

    var displayText: String {
        return money.displayText + " " + currency.title
    }

    var displayTextWithoutCurrencyName: String {
        return money.displayText
    }

}
