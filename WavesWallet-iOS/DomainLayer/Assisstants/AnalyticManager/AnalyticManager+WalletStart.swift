//
//  AnalyticManager+WalletStart.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/22/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension AnalyticManager.Event {
    enum WalletStart {
        
        private static let key = "Currency"
        
        /* Необходимо запоминать нулевые балансы для нашего general листа и
         при пополнении ассета любым способом отправлять событие.
         Изменение баланса с нуля, считаем только 1 раз. */
        case balanceFromZero(assetName: String)
        
        var name: String {
            switch self {
            case .balanceFromZero:
                return "Wallet Start Balance from Zero"
            }
        }
        
        var params: [String: String] {
            switch self {
            case .balanceFromZero(let assetName):
                return [WalletStart.key: assetName]
            }
        }
    }
    
}
