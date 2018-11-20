//
//  StartLeasingTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol StartLeasingErrorDelegate: AnyObject {
    func startLeasingDidFail()
}

enum StartLeasingTypes {
    
    enum Kind {
        case send(StartLeasingTypes.DTO.Order)
        case cancel
    }
    
    enum DTO {
        
        struct Order {
            var recipient: String
            var amount: Money
            let fee = GlobalConstants.WavesTransactionFee
        }
       
    }
}

