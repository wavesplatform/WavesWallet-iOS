//
//  ReceiveInfoTypes.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 10/6/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum ReceiveInvoice {
    enum DTO {}
}

extension ReceiveInvoice.DTO {

    struct DisplayInfo {
        let address: String
        let invoiceLink: String
        let assetName: String
        let icon: String
        let isSponsored: Bool
    }
}
