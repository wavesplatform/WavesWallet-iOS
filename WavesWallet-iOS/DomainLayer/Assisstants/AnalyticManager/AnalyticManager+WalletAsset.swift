//
//  AnalyticManager+WalletAsset.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 3/22/19.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

extension AnalyticManager.Event {

    enum WalletAsset {
        
        private static let key = "Currency"
        
        /* Нажата кнопка «Continue» у любой криптовалюты или токена. */
        case sendTap(assetName: String)
        
        /* Нажата кнопка «Confirm» у любой криптовалюты или токена. */
        case sendConfirm(assetName: String)
        
        /* Нажата кнопка «Continue» у любой криптовалюты или токена. */
        case receiveTap(assetName: String)
        
        /* Нажата кнопка «Confirm» у любой криптовалюты или токена. */
        case receiveConfirm(assetName: String)
        
        /* Нажата кнопка «Continue» на экране с заполненными полями карты. */
        case cardReceiveTap
        
        
        var name: String {
            switch self {
            case .sendTap:
                return "Wallet Assets Send Tap"
                
            case .sendConfirm:
                return "Wallet Assets Send Confirm"
                
            case .receiveTap:
                return "Wallet Assets Receive Tap"
                
            case .receiveConfirm:
                return "Wallet Assets Receive Confirm"
                
            case .cardReceiveTap:
                return "Wallet Assets Card Receive Tap"
            }
        }
        
        
        var params: [String : String] {
            switch self {
            case .sendTap(let assetName):
                return [WalletAsset.key: assetName]
                
            case .sendConfirm(let assetName):
                return [WalletAsset.key: assetName]
                
            case .receiveTap(let assetName):
                return [WalletAsset.key: assetName]
                
            case .receiveConfirm(let assetName):
                return [WalletAsset.key: assetName]
                
            default:
                return [:]
            }
        }
    }
}
