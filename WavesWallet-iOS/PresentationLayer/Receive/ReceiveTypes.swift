//
//  ReceiveTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/3/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum Receive {
    enum ViewModel {}
    enum DTO {}
}

extension Receive.DTO {
    
    struct Asset {
        let id: String
        let name: String
        let ticker: String
        let money: Money
    }
}

extension Receive.ViewModel {
    
    enum State: Int {
        case cryptoCurrency
        case invoice
        case card
    }
 
}
