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
}

extension ReceiveGenerate.DTO {
    
    enum GenerateType {
        case cryptoCurrency(ReceiveCryptocurrency.DTO.DisplayInfo)
        case invoice(ReceiveInvoice.DTO.DisplayInfo)
    }
}
