//
//  Balance.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

public struct Balance: Equatable {
    public struct Currency: Equatable {
        public let title: String
        public let ticker: String?
        
        public init(title: String, ticker: String?) {
            self.title = title
            self.ticker = ticker
        }
    }

    public let currency: Currency
    public let money: Money
    
    public init(currency: Currency, money: Money) {
        self.currency = currency
        self.money = money
    }
}

public extension Balance {

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
