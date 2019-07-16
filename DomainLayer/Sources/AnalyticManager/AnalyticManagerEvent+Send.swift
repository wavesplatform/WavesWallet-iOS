//
//  Send.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum Send: AnalyticManagerEventInfo {
        
        private static let key = "Currency"
        
        /* Нажата кнопка «Continue» у любой криптовалюты или токена. */
        case sendTap(assetName: String)
        
        /* Нажата кнопка «Confirm» у любой криптовалюты или токена. */
        case sendConfirm(assetName: String)
        
        public var name: String {
            switch self {
            case .sendTap:
                return "Wallet Assets Send Tap"
                
            case .sendConfirm:
                return "Wallet Assets Send Confirm"
            }
        }
        
        public var params: [String : String] {
            switch self {
            case .sendTap(let assetName):
                return [Send.key: assetName]
                
            case .sendConfirm(let assetName):
                return [Send.key: assetName]
            }
        }
    }
}
