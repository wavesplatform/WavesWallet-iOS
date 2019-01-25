//
//  StartLeasingTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 9/29/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

protocol StartLeasingErrorDelegate: AnyObject {
    func startLeasingDidFail(error: NetworkError)
}

protocol StartLeasingModuleOutput: AnyObject {
    func startLeasingDidSuccess(transaction: DomainLayer.DTO.SmartTransaction, kind: StartLeasingTypes.Kind)
}

enum StartLeasingTypes {
    
    struct Input {
        let kind: StartLeasingTypes.Kind
        let errorDelegate: StartLeasingErrorDelegate?
        let output: StartLeasingModuleOutput?
    }
    
    enum Kind {
        case send(StartLeasingTypes.DTO.Order)
        case cancel(StartLeasingTypes.DTO.CancelOrder)
    }
    
    enum DTO {
        
        struct Order {
            var recipient: String
            var amount: Money
            var fee: Money
        }
        
        struct CancelOrder {
            let leasingTX: String
            let amount: Money
            var fee: Money
        }
       
    }
}

