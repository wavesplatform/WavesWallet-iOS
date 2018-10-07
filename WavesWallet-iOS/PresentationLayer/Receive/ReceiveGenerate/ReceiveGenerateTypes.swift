//
//  ReceiveGenerateTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveGenerate {
    enum DTO {}
    
    enum Event {
        case invoiceDidCreate(Responce<ReceiveInvoive.DTO.DisplayInfo>)
    }
    
    struct State: Mutating {
        enum Action {
            case none
            case invoiceDidFailCreate(Error)
            case invoiceDidCreate(ReceiveInvoive.DTO.DisplayInfo)
        }
        
        var isNeedCreateInvoice: Bool
        var invoiceGenerateInfo: ReceiveInvoive.DTO.GenerateInfo?
        var action: Action
    }
}

extension ReceiveGenerate.DTO {
    
    enum GenerateType {
        case cryproCurrency(ReceiveCryptocurrency.DTO.DisplayInfo)
        case invoice(ReceiveInvoive.DTO.GenerateInfo)
    }
}
