//
//  Balance.swift
//  WavesWallet-iOS
//
//  Created by Prokofev Ruslan on 07/09/2018.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation
import Extensions

public extension DomainLayer.DTO {
    
    /// Сущность Баланса ассета
    struct Balance: Hashable {
        
        /// Сущность криптовалюты
        public struct Currency: Hashable {
            
            /// Название валюты
            public let title: String
            
            /// Обозначение валюты в бирже
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
}

public extension DomainLayer.DTO.Balance {

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

public extension DomainLayer.DTO.Balance.Currency {
    
    var displayText: String {
        return ticker ?? title
    }
}
