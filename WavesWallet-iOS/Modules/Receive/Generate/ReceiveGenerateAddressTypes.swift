//
//  ReceiveGenerateTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Exchange. All rights reserved.
//

import Foundation

enum ReceiveGenerateAddress {
    enum DTO {}
}

extension ReceiveGenerateAddress.DTO {
    
    enum GenerateType {
        case cryptoCurrency(ReceiveCryptocurrency.DTO.DisplayInfo)
        case invoice(ReceiveInvoice.DTO.DisplayInfo)
    }
}

extension ReceiveGenerateAddress.DTO.GenerateType {
    
    var cryptoCurrency: ReceiveCryptocurrency.DTO.DisplayInfo? {
        switch self {
        case .cryptoCurrency(let model):
            return model
        default:
            return nil
        }
    }
    
    var invoice: ReceiveInvoice.DTO.DisplayInfo? {
        switch self {
        case .invoice(let model):
            return model
        default:
            return nil
        }
    }
    
}
