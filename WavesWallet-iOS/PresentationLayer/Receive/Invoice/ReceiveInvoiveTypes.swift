//
//  ReceiveInfoTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveInvoive {
    enum DTO {}
}

extension ReceiveInvoive.DTO {

    struct GenerateInfo {
        let balanceAsset: DomainLayer.DTO.AssetBalance
        let amount: Money
    }
    
    struct DisplayInfo {
        let address: String
        let invoiceLink: String
        let assetName: String
    }
}
