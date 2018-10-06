//
//  ReceiveCryptocurrencyTapes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/5/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveCryptocurrency {
    enum DTO {}
    
    enum Event {
        case generateAddress(ticker: String, generalTicker: String)
        case addressDidGenerate(Responce<DTO.DisplayInfo>)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case addressDidGenerate(DTO.DisplayInfo)
            case addressDidFailGenerate(Error)
//            case addressDidFailGenerate(Error)
//            case orderDidFailCreate(Error)
//            case orderDidCreate
        }
        
        var isNeedGenerateAddress: Bool
        var action: Action
        var displayInfo: DTO.DisplayInfo?
        var ticker: String
        var generalTicker: String
    }
}

extension ReceiveCryptocurrency.DTO {
    
    struct DisplayInfo {
        let address: String
        let assetFullName: String
        let assetTicker: String
        let fee: String
    }
}
