//
//  Receive.swift
//  WavesWallet-iOS
//
//  Created by rprokofev on 26.06.2019.
//  Copyright © 2019 Waves Platform. All rights reserved.
//

import Foundation

public extension AnalyticManagerEvent {
    
    enum Receive: AnalyticManagerEventInfo {
        
        private static let key = "Currency"
        
        /* Нажата кнопка «Continue» у любой криптовалюты или токена. */
        case receiveTap(assetName: String)
        
        /* Нажата кнопка «Continue» на экране с заполненными полями карты. */
        case cardReceiveTap
        
        
        public var name: String {
            switch self {
                
            case .receiveTap:
                return "Wallet Assets Receive Tap"
                
            case .cardReceiveTap:
                return "Wallet Assets Card Receive Tap"
            }
        }
        
        public var params: [String : String] {
            switch self {
                
            case .receiveTap(let assetName):
                return [Receive.key: assetName]
                
            default:
                return [:]
            }
        }
    }
}
